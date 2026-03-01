-- ================================================================
-- PROMOTION_TOGGLE_FEATURED: Öne çıkan durumu değiştir
-- ================================================================

DROP FUNCTION IF EXISTS content.promotion_toggle_featured(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION content.promotion_toggle_featured(
    p_id                INTEGER,
    p_user_id           INTEGER
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_featured BOOLEAN;
BEGIN
    IF p_id IS NULL THEN RAISE EXCEPTION 'error.promotion.id-required'; END IF;

    UPDATE content.promotions
    SET is_featured = NOT is_featured,
        updated_by = p_user_id, updated_at = NOW()
    WHERE id = p_id AND is_active = TRUE
    RETURNING is_featured INTO v_new_featured;

    IF v_new_featured IS NULL THEN
        RAISE EXCEPTION 'error.promotion.not-found';
    END IF;

    RETURN v_new_featured;
END;
$$;

COMMENT ON FUNCTION content.promotion_toggle_featured(INTEGER, INTEGER) IS 'Toggle promotion featured status. Returns new is_featured state.';
