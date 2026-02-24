-- ================================================================
-- ADMIN_MESSAGE_TEMPLATE_DELETE: Bildirim şablonu silme
-- Soft delete (is_active = FALSE)
-- Sistem şablonları (is_system = TRUE) silinemez
-- ================================================================

DROP FUNCTION IF EXISTS messaging.admin_message_template_delete(BIGINT, INTEGER);

CREATE OR REPLACE FUNCTION messaging.admin_message_template_delete(
    p_caller_id     BIGINT,                          -- İşlemi yapan kullanıcı ID
    p_id            INTEGER                          -- Şablon ID
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_is_system BOOLEAN;
BEGIN
    -- Şablon varlık kontrolü
    SELECT is_system INTO v_is_system
    FROM messaging.message_templates
    WHERE id = p_id AND is_active = TRUE;

    IF v_is_system IS NULL THEN
        RAISE EXCEPTION 'error.notification-template.not-found';
    END IF;

    -- Sistem şablonu kontrolü
    IF v_is_system = TRUE THEN
        RAISE EXCEPTION 'error.notification-template.system-template-cannot-be-deleted';
    END IF;

    -- Soft delete
    UPDATE messaging.message_templates
    SET is_active = FALSE,
        updated_at = now(),
        updated_by = p_caller_id
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION messaging.admin_message_template_delete(BIGINT, INTEGER) IS 'Soft delete a platform message template. System templates (is_system=true) cannot be deleted.';
