-- ================================================================
-- SLIDE_DELETE: Slide soft delete (is_deleted)
-- ================================================================

DROP FUNCTION IF EXISTS content.slide_delete(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION content.slide_delete(
    p_id                INTEGER,
    p_user_id           INTEGER
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_id IS NULL THEN RAISE EXCEPTION 'error.slide.id-required'; END IF;

    IF NOT EXISTS (SELECT 1 FROM content.slides WHERE id = p_id AND is_deleted = FALSE) THEN
        RAISE EXCEPTION 'error.slide.not-found';
    END IF;

    UPDATE content.slides
    SET is_deleted = TRUE, deleted_at = NOW(), deleted_by = p_user_id,
        is_active = FALSE, updated_by = p_user_id, updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION content.slide_delete(INTEGER, INTEGER) IS 'Soft delete slide (sets is_deleted=TRUE, is_active=FALSE).';
