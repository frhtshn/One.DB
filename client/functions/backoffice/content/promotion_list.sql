-- ================================================================
-- PROMOTION_LIST: Promosyon listesi
-- Tip, durum, öne çıkan filtreli, sayfalanmış
-- ================================================================

DROP FUNCTION IF EXISTS content.promotion_list(INTEGER, BOOLEAN, BOOLEAN, CHAR, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION content.promotion_list(
    p_promotion_type_id INTEGER     DEFAULT NULL,
    p_is_active         BOOLEAN     DEFAULT NULL,
    p_is_featured       BOOLEAN     DEFAULT NULL,
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
    FROM content.promotions p
    WHERE (p_promotion_type_id IS NULL OR p.promotion_type_id = p_promotion_type_id)
      AND (p_is_active IS NULL OR p.is_active = p_is_active)
      AND (p_is_featured IS NULL OR p.is_featured = p_is_featured);

    SELECT COALESCE(jsonb_agg(row_data ORDER BY sort_order, created_at DESC), '[]'::JSONB)
    INTO v_items
    FROM (
        SELECT jsonb_build_object(
            'id', p.id, 'code', p.code, 'promotionTypeId', p.promotion_type_id,
            'bonusId', p.bonus_id, 'startDate', p.start_date, 'endDate', p.end_date,
            'sortOrder', p.sort_order, 'isFeatured', p.is_featured,
            'isNewMembersOnly', p.is_new_members_only, 'isActive', p.is_active,
            'title', t.title, 'summary', t.summary, 'createdAt', p.created_at
        ) AS row_data, p.sort_order, p.created_at
        FROM content.promotions p
        LEFT JOIN content.promotion_translations t
            ON t.promotion_id = p.id AND t.language_code = p_language_code
        WHERE (p_promotion_type_id IS NULL OR p.promotion_type_id = p_promotion_type_id)
          AND (p_is_active IS NULL OR p.is_active = p_is_active)
          AND (p_is_featured IS NULL OR p.is_featured = p_is_featured)
        ORDER BY p.sort_order, p.created_at DESC
        OFFSET p_offset LIMIT p_limit
    ) sub;

    RETURN jsonb_build_object('items', v_items, 'totalCount', v_total_count);
END;
$$;

COMMENT ON FUNCTION content.promotion_list(INTEGER, BOOLEAN, BOOLEAN, CHAR, INTEGER, INTEGER) IS 'List promotions with type, active, and featured filters. Paginated.';
