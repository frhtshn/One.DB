-- ================================================================
-- ADMIN_MESSAGE_DRAFT_CREATE: Mesaj taslağı oluşturur
-- scheduled_at verilirse status otomatik 'scheduled' olur
-- tenant_ids array olarak çoklu tenant destekler
-- Caller scope kontrolü: company_id ve tenant_ids erişim doğrulaması
-- ================================================================

DROP FUNCTION IF EXISTS messaging.admin_message_draft_create(BIGINT, BIGINT, VARCHAR, TEXT, VARCHAR, VARCHAR, BIGINT, BIGINT[], BIGINT, BIGINT, TIMESTAMP, TIMESTAMP, BIGINT);
DROP FUNCTION IF EXISTS messaging.admin_message_draft_create(BIGINT, BIGINT, VARCHAR, TEXT, VARCHAR, VARCHAR, BIGINT, BIGINT[], BIGINT, BIGINT, TIMESTAMPTZ, TIMESTAMPTZ, BIGINT);

CREATE OR REPLACE FUNCTION messaging.admin_message_draft_create(
    p_caller_id     BIGINT,                                   -- İşlemi yapan kullanıcı ID
    p_sender_id     BIGINT,                                   -- Gönderen admin ID
    p_subject       VARCHAR(500),                             -- Mesaj konusu
    p_body          TEXT,                                      -- Mesaj içeriği (HTML)
    p_message_type  VARCHAR(30) DEFAULT 'announcement',       -- Mesaj tipi
    p_priority      VARCHAR(10) DEFAULT 'normal',             -- Öncelik seviyesi
    p_company_id    BIGINT DEFAULT NULL,                      -- Şirket filtresi
    p_tenant_ids    BIGINT[] DEFAULT NULL,                    -- Tenant filtresi (çoklu)
    p_department_id BIGINT DEFAULT NULL,                      -- Departman filtresi
    p_role_id       BIGINT DEFAULT NULL,                      -- Rol filtresi
    p_scheduled_at  TIMESTAMPTZ DEFAULT NULL,                 -- Zamanlama (NULL = draft)
    p_expires_at    TIMESTAMPTZ DEFAULT NULL,                 -- Mesaj süre sonu
    p_created_by    BIGINT DEFAULT NULL                       -- Oluşturan (NULL ise caller_id)
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_draft_id INTEGER;
    v_status VARCHAR(20);
BEGIN
    -- Zorunlu alan kontrolleri
    IF p_caller_id IS NULL THEN
        RAISE EXCEPTION 'error.messaging.sender-id-required' USING ERRCODE = 'P0400';
    END IF;

    IF p_subject IS NULL OR p_subject = '' THEN
        RAISE EXCEPTION 'error.messaging.subject-required' USING ERRCODE = 'P0400';
    END IF;

    IF p_body IS NULL OR p_body = '' THEN
        RAISE EXCEPTION 'error.messaging.body-required' USING ERRCODE = 'P0400';
    END IF;

    -- Scope kontrolü: caller hedef company'ye erişebilir mi?
    IF p_company_id IS NOT NULL THEN
        PERFORM security.user_assert_access_company(p_caller_id, p_company_id);
    END IF;

    -- Scope kontrolü: caller hedef tenant'lara erişebilir mi?
    IF p_tenant_ids IS NOT NULL AND array_length(p_tenant_ids, 1) > 0 THEN
        PERFORM security.user_assert_access_tenant(p_caller_id, tid)
        FROM unnest(p_tenant_ids) AS tid;
    END IF;

    -- Status belirleme: scheduled_at varsa → scheduled, yoksa → draft
    v_status := CASE WHEN p_scheduled_at IS NOT NULL THEN 'scheduled' ELSE 'draft' END;

    -- Draft oluştur
    INSERT INTO messaging.user_message_drafts (
        sender_id, subject, body, message_type, priority,
        company_id, tenant_ids, department_id, role_id,
        status, scheduled_at, expires_at,
        created_by
    ) VALUES (
        COALESCE(p_sender_id, p_caller_id), p_subject, p_body, p_message_type, p_priority,
        p_company_id, p_tenant_ids, p_department_id, p_role_id,
        v_status, p_scheduled_at, p_expires_at,
        COALESCE(p_created_by, p_caller_id)
    )
    RETURNING id INTO v_draft_id;

    RETURN v_draft_id;
END;
$$;

COMMENT ON FUNCTION messaging.admin_message_draft_create(BIGINT, BIGINT, VARCHAR, TEXT, VARCHAR, VARCHAR, BIGINT, BIGINT[], BIGINT, BIGINT, TIMESTAMPTZ, TIMESTAMPTZ, BIGINT) IS 'Create a message draft with caller scope validation. Validates caller access to company_id and tenant_ids. Returns draft ID.';
