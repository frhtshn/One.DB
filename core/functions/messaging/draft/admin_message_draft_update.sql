-- ================================================================
-- ADMIN_MESSAGE_DRAFT_UPDATE: Mesaj taslağını günceller
-- Sadece draft durumundakiler güncellenebilir
-- NULL parametreler mevcut değeri korur (COALESCE — partial update)
-- client_ids array olarak çoklu client destekler
-- Caller scope kontrolü: company_id ve client_ids erişim doğrulaması
-- Ownership kontrolü: sender_id != p_caller_id AND NOT p_is_admin → RAISE
-- ================================================================

DROP FUNCTION IF EXISTS messaging.admin_message_draft_update(BIGINT, INTEGER, VARCHAR, TEXT, VARCHAR, VARCHAR, BIGINT, BIGINT[], BIGINT, BIGINT, TIMESTAMP, TIMESTAMP);
DROP FUNCTION IF EXISTS messaging.admin_message_draft_update(BIGINT, INTEGER, VARCHAR, TEXT, VARCHAR, VARCHAR, BIGINT, BIGINT[], BIGINT, BIGINT, TIMESTAMPTZ, TIMESTAMPTZ, BOOLEAN);

CREATE OR REPLACE FUNCTION messaging.admin_message_draft_update(
    p_caller_id     BIGINT,                                   -- İşlemi yapan kullanıcı ID
    p_draft_id      INTEGER,                                  -- Güncellenecek draft ID
    p_subject       VARCHAR(500) DEFAULT NULL,                -- Mesaj konusu (NULL = değiştirme)
    p_body          TEXT DEFAULT NULL,                         -- Mesaj içeriği (NULL = değiştirme)
    p_message_type  VARCHAR(30) DEFAULT NULL,                 -- Mesaj tipi (NULL = değiştirme)
    p_priority      VARCHAR(10) DEFAULT NULL,                 -- Öncelik (NULL = değiştirme)
    p_company_id    BIGINT DEFAULT NULL,                      -- Şirket filtresi
    p_client_ids    BIGINT[] DEFAULT NULL,                    -- Client filtresi (çoklu)
    p_department_id BIGINT DEFAULT NULL,                      -- Departman filtresi
    p_role_id       BIGINT DEFAULT NULL,                      -- Rol filtresi
    p_scheduled_at  TIMESTAMPTZ DEFAULT NULL,                 -- Zamanlama
    p_expires_at    TIMESTAMPTZ DEFAULT NULL,                 -- Süre sonu
    p_is_admin      BOOLEAN DEFAULT FALSE                     -- SuperAdmin bypass
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_sender_id BIGINT;
    v_status VARCHAR(20);
BEGIN
    IF p_caller_id IS NULL THEN
        RAISE EXCEPTION 'error.messaging.sender-id-required' USING ERRCODE = 'P0400';
    END IF;

    IF p_draft_id IS NULL THEN
        RAISE EXCEPTION 'error.messaging.draft-id-required' USING ERRCODE = 'P0400';
    END IF;

    -- Draft bilgilerini al
    SELECT sender_id, status INTO v_sender_id, v_status
    FROM messaging.user_message_drafts
    WHERE id = p_draft_id
      AND is_deleted = FALSE;

    IF v_sender_id IS NULL THEN
        RAISE EXCEPTION 'error.messaging.draft-not-found' USING ERRCODE = 'P0404';
    END IF;

    -- Ownership kontrolü
    IF v_sender_id != p_caller_id AND NOT p_is_admin THEN
        RAISE EXCEPTION 'error.messaging.not-draft-owner' USING ERRCODE = 'P0403';
    END IF;

    -- Status kontrolü: sadece draft durumunda güncellenebilir
    IF v_status != 'draft' THEN
        RAISE EXCEPTION 'error.messaging.draft-not-editable' USING ERRCODE = 'P0400';
    END IF;

    -- Scope kontrolü: caller hedef company'ye erişebilir mi?
    IF p_company_id IS NOT NULL THEN
        PERFORM security.user_assert_access_company(p_caller_id, p_company_id);
    END IF;

    -- Scope kontrolü: caller hedef client'lara erişebilir mi?
    IF p_client_ids IS NOT NULL AND array_length(p_client_ids, 1) > 0 THEN
        PERFORM security.user_assert_access_client(p_caller_id, tid)
        FROM unnest(p_client_ids) AS tid;
    END IF;

    -- TÜM alanlara COALESCE: NULL = mevcut değer korunur
    UPDATE messaging.user_message_drafts
    SET subject = COALESCE(p_subject, subject),
        body = COALESCE(p_body, body),
        message_type = COALESCE(p_message_type, message_type),
        priority = COALESCE(p_priority, priority),
        company_id = COALESCE(p_company_id, company_id),
        client_ids = COALESCE(p_client_ids, client_ids),
        department_id = COALESCE(p_department_id, department_id),
        role_id = COALESCE(p_role_id, role_id),
        scheduled_at = COALESCE(p_scheduled_at, scheduled_at),
        expires_at = COALESCE(p_expires_at, expires_at),
        status = CASE WHEN COALESCE(p_scheduled_at, scheduled_at) IS NOT NULL THEN 'scheduled' ELSE 'draft' END,
        updated_at = NOW()
    WHERE id = p_draft_id;

    RETURN TRUE;
END;
$$;

COMMENT ON FUNCTION messaging.admin_message_draft_update(BIGINT, INTEGER, VARCHAR, TEXT, VARCHAR, VARCHAR, BIGINT, BIGINT[], BIGINT, BIGINT, TIMESTAMPTZ, TIMESTAMPTZ, BOOLEAN) IS 'Update a message draft with ownership and scope validation. All fields use COALESCE — NULL preserves existing value. Only draft status can be updated.';
