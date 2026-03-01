-- ================================================================
-- PROMOTION_DELETE: Promosyon soft delete
-- ================================================================

DROP FUNCTION IF EXISTS content.promotion_delete(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION content.promotion_delete(
    p_id                INTEGER,
    p_user_id           INTEGER
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_id IS NULL THEN RAISE EXCEPTION 'error.promotion.id-required'; END IF;

    IF NOT EXISTS (SELECT 1 FROM content.promotions WHERE id = p_id AND is_active = TRUE) THEN
        RAISE EXCEPTION 'error.promotion.not-found';
    END IF;

    UPDATE content.promotions
    SET is_active = FALSE, updated_by = p_user_id, updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION content.promotion_delete(INTEGER, INTEGER) IS 'Soft delete promotion (is_active=FALSE).';
