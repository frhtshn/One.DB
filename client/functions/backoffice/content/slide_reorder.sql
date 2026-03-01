-- ================================================================
-- SLIDE_REORDER: Sıralama güncelle (placement içinde)
-- Array index → sort_order olarak günceller
-- ================================================================

DROP FUNCTION IF EXISTS content.slide_reorder(INTEGER, INTEGER[], INTEGER);

CREATE OR REPLACE FUNCTION content.slide_reorder(
    p_placement_id      INTEGER,
    p_slide_ids         INTEGER[],
    p_user_id           INTEGER
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_slide_id INTEGER;
    v_order INTEGER := 0;
BEGIN
    IF p_placement_id IS NULL THEN RAISE EXCEPTION 'error.slide.placement-id-required'; END IF;
    IF p_slide_ids IS NULL OR array_length(p_slide_ids, 1) IS NULL THEN
        RAISE EXCEPTION 'error.slide.slide-ids-required';
    END IF;

    FOREACH v_slide_id IN ARRAY p_slide_ids
    LOOP
        UPDATE content.slides
        SET sort_order = v_order,
            updated_by = p_user_id,
            updated_at = NOW()
        WHERE id = v_slide_id AND placement_id = p_placement_id AND is_deleted = FALSE;

        v_order := v_order + 1;
    END LOOP;
END;
$$;

COMMENT ON FUNCTION content.slide_reorder(INTEGER, INTEGER[], INTEGER) IS 'Reorder slides within a placement. Array index becomes sort_order.';
