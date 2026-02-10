-- ================================================================
-- ADMIN_MESSAGE_DRAFT_UPDATE: Mesaj taslağını günceller
-- Sadece draft veya scheduled durumundakiler güncellenebilir
-- NULL parametreler mevcut değeri korur (partial update)
-- tenant_ids array olarak çoklu tenant destekler
-- ================================================================

DROP FUNCTION IF EXISTS messaging.admin_message_draft_update(INTEGER, VARCHAR, TEXT, VARCHAR, VARCHAR, BIGINT, BIGINT[], BIGINT, BIGINT, TIMESTAMP, TIMESTAMP);

CREATE OR REPLACE FUNCTION messaging.admin_message_draft_update(
    p_draft_id      INTEGER,                          -- Güncellenecek draft ID
    p_subject       VARCHAR(500) DEFAULT NULL,        -- Mesaj konusu (NULL = değiştirme)
    p_body          TEXT DEFAULT NULL,                 -- Mesaj içeriği (NULL = değiştirme)
    p_message_type  VARCHAR(30) DEFAULT NULL,         -- Mesaj tipi (NULL = değiştirme)
    p_priority      VARCHAR(10) DEFAULT NULL,         -- Öncelik (NULL = değiştirme)
    p_company_id    BIGINT DEFAULT NULL,              -- Şirket filtresi
    p_tenant_ids    BIGINT[] DEFAULT NULL,            -- Tenant filtresi (çoklu)
    p_department_id BIGINT DEFAULT NULL,              -- Departman filtresi
    p_role_id       BIGINT DEFAULT NULL,              -- Rol filtresi
    p_scheduled_at  TIMESTAMP DEFAULT NULL,           -- Zamanlama
    p_expires_at    TIMESTAMP DEFAULT NULL            -- Süre sonu
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_updated INTEGER;
BEGIN
    IF p_draft_id IS NULL THEN
        RAISE EXCEPTION 'error.messaging.draft-id-required';
    END IF;

    -- Sadece draft/scheduled durumundakiler güncellenebilir
    UPDATE messaging.user_message_drafts
    SET subject = COALESCE(p_subject, subject),
        body = COALESCE(p_body, body),
        message_type = COALESCE(p_message_type, message_type),
        priority = COALESCE(p_priority, priority),
        company_id = p_company_id,
        tenant_ids = p_tenant_ids,
        department_id = p_department_id,
        role_id = p_role_id,
        scheduled_at = p_scheduled_at,
        expires_at = p_expires_at,
        status = CASE WHEN p_scheduled_at IS NOT NULL THEN 'scheduled' ELSE 'draft' END,
        updated_at = NOW()
    WHERE id = p_draft_id
      AND status IN ('draft', 'scheduled')
      AND is_deleted = FALSE;

    GET DIAGNOSTICS v_updated = ROW_COUNT;

    IF v_updated = 0 THEN
        RAISE EXCEPTION 'error.messaging.draft-not-found-or-published';
    END IF;

    RETURN TRUE;
END;
$$;

COMMENT ON FUNCTION messaging.admin_message_draft_update(INTEGER, VARCHAR, TEXT, VARCHAR, VARCHAR, BIGINT, BIGINT[], BIGINT, BIGINT, TIMESTAMP, TIMESTAMP) IS 'Update a message draft. Only draft/scheduled status can be updated. NULL parameters keep current values (except filter fields which are always overwritten). tenant_ids supports multi-tenant targeting. Returns TRUE on success.';
