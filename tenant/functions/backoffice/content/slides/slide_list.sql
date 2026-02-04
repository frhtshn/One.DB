-- ================================================================
-- SLIDE_LIST: Slide listesi (Backoffice)
-- ================================================================
-- NOT: Yetki kontrolü Core DB'de yapılır (user_assert_access_tenant)
-- Bu function sadece iş mantığını içerir.
-- ================================================================

DROP FUNCTION IF EXISTS content.slide_list(INTEGER, INTEGER, INTEGER, BOOLEAN, TEXT);

CREATE OR REPLACE FUNCTION content.slide_list(
    p_page INTEGER DEFAULT 1,
    p_page_size INTEGER DEFAULT 20,
    p_placement_id INTEGER DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL,
    p_search TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_offset INTEGER;
    v_total_count INTEGER;
    v_items JSONB;
BEGIN
    v_offset := (p_page - 1) * p_page_size;

    -- Total count
    SELECT COUNT(*) INTO v_total_count
    FROM content.slides s
    WHERE s.is_deleted = FALSE
      AND (p_placement_id IS NULL OR s.placement_id = p_placement_id)
      AND (p_is_active IS NULL OR s.is_active = p_is_active)
      AND (p_search IS NULL OR s.code ILIKE '%' || p_search || '%');

    -- Items with translations
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', s.id,
            'code', s.code,
            'placementId', s.placement_id,
            'placementCode', sp.code,
            'categoryId', s.category_id,
            'sortOrder', s.sort_order,
            'priority', s.priority,
            'linkUrl', s.link_url,
            'linkType', s.link_type,
            'startDate', s.start_date,
            'endDate', s.end_date,
            'isActive', s.is_active,
            'createdAt', s.created_at,
            'updatedAt', s.updated_at,
            -- İlk resim (thumbnail için)
            'thumbnail', (
                SELECT si.image_url
                FROM content.slide_images si
                WHERE si.slide_id = s.id
                ORDER BY si.is_default DESC, si.id
                LIMIT 1
            )
        ) ORDER BY s.sort_order, s.priority DESC
    ), '[]'::jsonb)
    INTO v_items
    FROM (
        SELECT * FROM content.slides
        WHERE is_deleted = FALSE
          AND (p_placement_id IS NULL OR placement_id = p_placement_id)
          AND (p_is_active IS NULL OR is_active = p_is_active)
          AND (p_search IS NULL OR code ILIKE '%' || p_search || '%')
        ORDER BY sort_order, priority DESC
        LIMIT p_page_size OFFSET v_offset
    ) s
    LEFT JOIN content.slide_placements sp ON sp.id = s.placement_id;

    RETURN jsonb_build_object(
        'items', v_items,
        'totalCount', v_total_count,
        'page', p_page,
        'pageSize', p_page_size
    );
END;
$$;

COMMENT ON FUNCTION content.slide_list IS 'Lists slides for backoffice. Auth check done in Core DB.';
