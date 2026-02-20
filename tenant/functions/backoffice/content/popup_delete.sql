-- ================================================================
-- POPUP_DELETE: Popup soft delete (is_deleted)
-- ================================================================

DROP FUNCTION IF EXISTS content.popup_delete(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION content.popup_delete(
    p_id                INTEGER,
    p_user_id           INTEGER
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_id IS NULL THEN
        RAISE EXCEPTION 'error.popup.id-required';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM content.popups WHERE id = p_id AND is_deleted = FALSE) THEN
        RAISE EXCEPTION 'error.popup.not-found';
    END IF;

    UPDATE content.popups
    SET is_deleted = TRUE, deleted_at = NOW(), deleted_by = p_user_id,
        is_active = FALSE, updated_by = p_user_id, updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION content.popup_delete(INTEGER, INTEGER) IS 'Soft delete popup (sets is_deleted=TRUE, is_active=FALSE).';
