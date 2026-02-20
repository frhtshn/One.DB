-- ================================================================
-- ADMIN_MESSAGE_PUBLISH: Draft'ı yayınlar
-- Draft'tan content ve filtreleri okur
-- Filtre bazlı alıcı çözümlemesi (AND kombinasyonu)
-- tenant_ids array ile çoklu tenant destekler
-- Her alıcı için ayrı mesaj satırı oluşturur (draft_id ile)
-- Draft status → published, total_recipients güncellenir
-- 0 alıcı çözümlenirse exception fırlatır (yayınlamaz)
-- >10K alıcı hard limit — atomik rollback
-- Caller scope kontrolü: draft'ın company_id ve tenant_ids erişim doğrulaması
-- Ownership kontrolü: sender_id != p_caller_id AND NOT p_is_admin → RAISE
-- ================================================================

DROP FUNCTION IF EXISTS messaging.admin_message_publish(BIGINT, INTEGER);
DROP FUNCTION IF EXISTS messaging.admin_message_publish(BIGINT, INTEGER, BOOLEAN);

CREATE OR REPLACE FUNCTION messaging.admin_message_publish(
    p_caller_id BIGINT,                    -- İşlemi yapan kullanıcı ID
    p_draft_id  INTEGER,                   -- Yayınlanacak draft ID
    p_is_admin  BOOLEAN DEFAULT FALSE      -- SuperAdmin bypass
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_draft RECORD;
    v_recipient_count INTEGER;
    v_has_tenant_filter BOOLEAN;
BEGIN
    IF p_caller_id IS NULL THEN
        RAISE EXCEPTION 'error.messaging.sender-id-required' USING ERRCODE = 'P0400';
    END IF;

    IF p_draft_id IS NULL THEN
        RAISE EXCEPTION 'error.messaging.draft-id-required' USING ERRCODE = 'P0400';
    END IF;

    -- Draft bilgilerini al
    SELECT * INTO v_draft
    FROM messaging.user_message_drafts
    WHERE id = p_draft_id
      AND is_deleted = FALSE;

    IF v_draft IS NULL THEN
        RAISE EXCEPTION 'error.messaging.draft-not-found' USING ERRCODE = 'P0404';
    END IF;

    -- Ownership kontrolü
    IF v_draft.sender_id != p_caller_id AND NOT p_is_admin THEN
        RAISE EXCEPTION 'error.messaging.not-draft-owner' USING ERRCODE = 'P0403';
    END IF;

    -- Sadece draft/scheduled yayınlanabilir
    IF v_draft.status NOT IN ('draft', 'scheduled') THEN
        RAISE EXCEPTION 'error.messaging.draft-already-published' USING ERRCODE = 'P0400';
    END IF;

    -- Scope kontrolü: caller draft'ın hedef company'sine erişebilir mi?
    IF v_draft.company_id IS NOT NULL THEN
        PERFORM security.user_assert_access_company(p_caller_id, v_draft.company_id);
    END IF;

    -- Scope kontrolü: caller draft'ın hedef tenant'larına erişebilir mi?
    IF v_draft.tenant_ids IS NOT NULL AND array_length(v_draft.tenant_ids, 1) > 0 THEN
        PERFORM security.user_assert_access_tenant(p_caller_id, tid)
        FROM unnest(v_draft.tenant_ids) AS tid;
    END IF;

    -- Tenant filtresi aktif mi kontrol et
    v_has_tenant_filter := v_draft.tenant_ids IS NOT NULL AND array_length(v_draft.tenant_ids, 1) > 0;

    -- Filtre bazlı alıcı çözümlemesi (AND kombinasyonu)
    WITH resolved_recipients AS (
        SELECT DISTINCT u.id AS recipient_id
        FROM security.users u
        WHERE u.status = 1
          AND u.id != v_draft.sender_id

          -- Şirket filtresi
          AND (v_draft.company_id IS NULL OR u.company_id = v_draft.company_id)

          -- Tenant filtresi (çoklu): açık erişim VEYA company superadmin
          AND (NOT v_has_tenant_filter OR (
              EXISTS (
                  SELECT 1 FROM security.user_allowed_tenants uat
                  WHERE uat.user_id = u.id AND uat.tenant_id = ANY(v_draft.tenant_ids)
              )
              OR (
                  EXISTS (
                      SELECT 1 FROM core.tenants t
                      WHERE t.id = ANY(v_draft.tenant_ids) AND t.company_id = u.company_id
                  )
                  AND NOT EXISTS (
                      SELECT 1 FROM security.user_allowed_tenants sat
                      WHERE sat.user_id = u.id
                  )
              )
          ))

          -- Departman filtresi
          AND (v_draft.department_id IS NULL OR EXISTS (
              SELECT 1 FROM core.user_departments ud
              WHERE ud.user_id = u.id AND ud.department_id = v_draft.department_id
          ))

          -- Rol filtresi (tenant varsa o tenant'lardaki veya global rol aranır)
          AND (v_draft.role_id IS NULL OR EXISTS (
              SELECT 1 FROM security.user_roles ur
              WHERE ur.user_id = u.id
                AND ur.role_id = v_draft.role_id
                AND (NOT v_has_tenant_filter OR ur.tenant_id IS NULL OR ur.tenant_id = ANY(v_draft.tenant_ids))
          ))
    )
    INSERT INTO messaging.user_messages (
        recipient_id, sender_id, draft_id,
        subject, body,
        message_type, priority, expires_at
    )
    SELECT
        rr.recipient_id,
        v_draft.sender_id,
        p_draft_id,
        v_draft.subject,
        v_draft.body,
        v_draft.message_type,
        v_draft.priority,
        v_draft.expires_at
    FROM resolved_recipients rr;

    GET DIAGNOSTICS v_recipient_count = ROW_COUNT;

    -- 0 alıcı kontrolü: filtreler hiç alıcı çözümleyemediyse yayınlama
    IF v_recipient_count = 0 THEN
        RAISE EXCEPTION 'error.messaging.no-recipients' USING ERRCODE = 'P0400';
    END IF;

    -- Hard limit: 10K alıcı
    IF v_recipient_count > 10000 THEN
        RAISE EXCEPTION 'error.messaging.too-many-recipients' USING ERRCODE = 'P0400';
    END IF;

    -- Draft'ı published olarak güncelle
    UPDATE messaging.user_message_drafts
    SET status = 'published',
        published_at = NOW(),
        total_recipients = v_recipient_count,
        updated_at = NOW()
    WHERE id = p_draft_id;

    RETURN v_recipient_count;
END;
$$;

COMMENT ON FUNCTION messaging.admin_message_publish(BIGINT, INTEGER, BOOLEAN) IS 'Publish a draft message with ownership and scope validation. Resolves recipients using AND-combined filters. Hard limit: 10K recipients. Raises error if no recipients matched. Returns recipient count.';
