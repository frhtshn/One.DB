-- ================================================================
-- POPUP_DELETE: Popup sil (Backoffice - Soft Delete)
-- ================================================================
-- NOT: Yetki kontrolü Core DB'de yapılır (user_assert_access_tenant)
-- Bu function sadece iş mantığını içerir.
-- ================================================================

DROP FUNCTION IF EXISTS content.popup_delete(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION content.popup_delete(
    p_id INTEGER,
    p_operator_id INTEGER DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Popup var mı kontrolü
    IF NOT EXISTS (SELECT 1 FROM content.popups WHERE id = p_id AND is_deleted = FALSE) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.popup.not-found';
    END IF;

    -- Soft delete
    UPDATE content.popups
    SET is_deleted = TRUE,
        is_active = FALSE,
        deleted_at = NOW(),
        deleted_by = p_operator_id,
        updated_at = NOW(),
        updated_by = p_operator_id
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION content.popup_delete IS 'Soft deletes a popup. Auth check done in Core DB.';
