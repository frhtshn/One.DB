-- ================================================================
-- SLIDE_PLACEMENT_LIST: Yerleşim alanları listesi
-- ================================================================

DROP FUNCTION IF EXISTS content.slide_placement_list();

CREATE OR REPLACE FUNCTION content.slide_placement_list()
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'id', sp.id, 'code', sp.code, 'name', sp.name, 'description', sp.description,
        'maxSlides', sp.max_slides, 'width', sp.width, 'height', sp.height,
        'aspectRatio', sp.aspect_ratio, 'isActive', sp.is_active,
        'slideCount', COALESCE(sc.cnt, 0)
    ) ORDER BY sp.code), '[]'::JSONB)
    INTO v_result
    FROM content.slide_placements sp
    LEFT JOIN (
        SELECT placement_id, COUNT(*) AS cnt
        FROM content.slides WHERE is_active = TRUE AND is_deleted = FALSE
        GROUP BY placement_id
    ) sc ON sc.placement_id = sp.id
    WHERE sp.is_active = TRUE;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION content.slide_placement_list() IS 'List active slide placements with current slide counts.';
