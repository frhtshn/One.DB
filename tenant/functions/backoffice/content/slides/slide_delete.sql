-- ================================================================
-- SLIDE_DELETE: Slide sil (Soft Delete)
-- ================================================================
-- NOT: Yetki kontrolü Core DB'de yapılır (user_assert_access_tenant)
-- ================================================================

DROP FUNCTION IF EXISTS content.slide_delete(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION content.slide_delete(
    p_id INTEGER,
    p_operator_id INTEGER DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Varlık kontrolü
    IF NOT EXISTS(SELECT 1 FROM content.slides WHERE id = p_id AND is_deleted = FALSE) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.slide.not-found';
    END IF;

    -- Soft delete
    UPDATE content.slides
    SET
        is_deleted = TRUE,
        is_active = FALSE,
        deleted_at = NOW(),
        deleted_by = p_operator_id
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION content.slide_delete IS 'Soft deletes a slide. Auth check done in Core DB.';
