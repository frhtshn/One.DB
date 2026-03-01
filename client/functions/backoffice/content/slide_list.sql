-- ================================================================
-- SLIDE_LIST: Slide listesi
-- Placement, kategori, durum filtreli, sayfalanmış
-- ================================================================

DROP FUNCTION IF EXISTS content.slide_list(INTEGER, INTEGER, BOOLEAN, CHAR, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION content.slide_list(
    p_placement_id      INTEGER     DEFAULT NULL,
    p_category_id       INTEGER     DEFAULT NULL,
    p_is_active         BOOLEAN     DEFAULT NULL,
    p_language_code     CHAR(2)     DEFAULT 'en',
    p_offset            INTEGER     DEFAULT 0,
    p_limit             INTEGER     DEFAULT 20
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_count INTEGER;
    v_items JSONB;
BEGIN
    SELECT COUNT(*) INTO v_total_count
    FROM content.slides s
    WHERE s.is_deleted = FALSE
      AND (p_placement_id IS NULL OR s.placement_id = p_placement_id)
      AND (p_category_id IS NULL OR s.category_id = p_category_id)
      AND (p_is_active IS NULL OR s.is_active = p_is_active);

    SELECT COALESCE(jsonb_agg(row_data ORDER BY sort_order), '[]'::JSONB)
    INTO v_items
    FROM (
        SELECT jsonb_build_object(
            'id', s.id, 'placementId', s.placement_id, 'categoryId', s.category_id,
            'code', s.code, 'sortOrder', s.sort_order, 'priority', s.priority,
            'linkType', s.link_type, 'startDate', s.start_date, 'endDate', s.end_date,
            'isActive', s.is_active, 'title', t.title, 'createdAt', s.created_at
        ) AS row_data, s.sort_order
        FROM content.slides s
        LEFT JOIN content.slide_translations t
            ON t.slide_id = s.id AND t.language_code = p_language_code
        WHERE s.is_deleted = FALSE
          AND (p_placement_id IS NULL OR s.placement_id = p_placement_id)
          AND (p_category_id IS NULL OR s.category_id = p_category_id)
          AND (p_is_active IS NULL OR s.is_active = p_is_active)
        ORDER BY s.sort_order
        OFFSET p_offset LIMIT p_limit
    ) sub;

    RETURN jsonb_build_object('items', v_items, 'totalCount', v_total_count);
END;
$$;

COMMENT ON FUNCTION content.slide_list(INTEGER, INTEGER, BOOLEAN, CHAR, INTEGER, INTEGER) IS 'List slides with placement, category, and active filters. Paginated.';
