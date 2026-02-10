-- ================================================================
-- ADMIN_MESSAGE_PUBLISH: Draft'ı yayınlar
-- Draft'tan content ve filtreleri okur
-- Filtre bazlı alıcı çözümlemesi (AND kombinasyonu)
-- tenant_ids array ile çoklu tenant destekler
-- Her alıcı için ayrı mesaj satırı oluşturur (draft_id ile)
-- Draft status → published, total_recipients güncellenir
-- ================================================================

DROP FUNCTION IF EXISTS messaging.admin_message_publish(INTEGER);

CREATE OR REPLACE FUNCTION messaging.admin_message_publish(
    p_draft_id INTEGER  -- Yayınlanacak draft ID
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_draft RECORD;
    v_recipient_count INTEGER;
    v_has_tenant_filter BOOLEAN;
BEGIN
    IF p_draft_id IS NULL THEN
        RAISE EXCEPTION 'error.messaging.draft-id-required';
    END IF;

    -- Draft bilgilerini al
    SELECT * INTO v_draft
    FROM messaging.user_message_drafts
    WHERE id = p_draft_id
      AND is_deleted = FALSE;

    IF v_draft IS NULL THEN
        RAISE EXCEPTION 'error.messaging.draft-not-found';
    END IF;

    -- Sadece draft/scheduled yayınlanabilir
    IF v_draft.status NOT IN ('draft', 'scheduled') THEN
        RAISE EXCEPTION 'error.messaging.draft-already-published';
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

COMMENT ON FUNCTION messaging.admin_message_publish(INTEGER) IS 'Publish a draft message. Reads content and filters from draft, resolves recipients using AND-combined filters (company/tenant_ids[]/department/role), creates individual user_messages with draft_id link. tenant_ids array supports multi-tenant targeting. Updates draft status to published. Returns recipient count.';
