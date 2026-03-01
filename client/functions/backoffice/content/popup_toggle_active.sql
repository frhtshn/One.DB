-- ================================================================
-- POPUP_TOGGLE_ACTIVE: Popup aktif/pasif değiştir
-- ================================================================

DROP FUNCTION IF EXISTS content.popup_toggle_active(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION content.popup_toggle_active(
    p_id                INTEGER,
    p_user_id           INTEGER
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_active BOOLEAN;
BEGIN
    IF p_id IS NULL THEN
        RAISE EXCEPTION 'error.popup.id-required';
    END IF;

    UPDATE content.popups
    SET is_active = NOT is_active,
        updated_by = p_user_id,
        updated_at = NOW()
    WHERE id = p_id AND is_deleted = FALSE
    RETURNING is_active INTO v_new_active;

    IF v_new_active IS NULL THEN
        RAISE EXCEPTION 'error.popup.not-found';
    END IF;

    RETURN v_new_active;
END;
$$;

COMMENT ON FUNCTION content.popup_toggle_active(INTEGER, INTEGER) IS 'Toggle popup active status. Returns new is_active state.';
