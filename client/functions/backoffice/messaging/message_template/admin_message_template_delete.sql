-- ================================================================
-- ADMIN_MESSAGE_TEMPLATE_DELETE: Bildirim şablonu silme
-- Soft delete (is_deleted = TRUE, deleted_at, deleted_by)
-- Sistem şablonları (is_system = TRUE) silinemez
-- ================================================================

DROP FUNCTION IF EXISTS messaging.admin_message_template_delete(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION messaging.admin_message_template_delete(
    p_user_id       INTEGER,                         -- İşlemi yapan kullanıcı ID
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
    WHERE id = p_id AND is_deleted = FALSE;

    IF v_is_system IS NULL THEN
        RAISE EXCEPTION 'error.notification-template.not-found';
    END IF;

    -- Sistem şablonu kontrolü
    IF v_is_system = TRUE THEN
        RAISE EXCEPTION 'error.notification-template.system-template-cannot-be-deleted';
    END IF;

    -- Soft delete
    UPDATE messaging.message_templates
    SET is_deleted = TRUE,
        deleted_at = now(),
        deleted_by = p_user_id,
        updated_at = now(),
        updated_by = p_user_id
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION messaging.admin_message_template_delete(INTEGER, INTEGER) IS 'Soft delete a client message template. System templates (is_system=true) cannot be deleted.';
