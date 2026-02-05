-- ================================================================
-- PROMOTION_LIST: Promosyon listesi (Backoffice)
-- ================================================================
-- NOT: Yetki kontrolü Core DB'de yapılır (user_assert_access_tenant)
-- Bu function sadece iş mantığını içerir.
-- ================================================================

DROP FUNCTION IF EXISTS content.promotion_list(INTEGER, INTEGER, INTEGER, BOOLEAN, BOOLEAN, TEXT);

CREATE OR REPLACE FUNCTION content.promotion_list(
    p_page INTEGER DEFAULT 1,
    p_page_size INTEGER DEFAULT 20,
    p_promotion_type_id INTEGER DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL,
    p_is_featured BOOLEAN DEFAULT NULL,
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
    FROM content.promotions p
    WHERE (p_promotion_type_id IS NULL OR p.promotion_type_id = p_promotion_type_id)
      AND (p_is_active IS NULL OR p.is_active = p_is_active)
      AND (p_is_featured IS NULL OR p.is_featured = p_is_featured)
      AND (p_search IS NULL OR p.code ILIKE '%' || p_search || '%');

    -- Items with first banner as thumbnail
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', p.id,
            'code', p.code,
            'promotionTypeId', p.promotion_type_id,
            'promotionTypeCode', pt.code,
            'promotionTypeIcon', pt.icon,
            'promotionTypeColor', pt.color,
            'promotionTypeBadge', pt.badge_text,
            'promotionTypeName', COALESCE(ptt.name, pt.code),
            'bonusId', p.bonus_id,
            'minDeposit', p.min_deposit,
            'maxDeposit', p.max_deposit,
            'startDate', p.start_date,
            'endDate', p.end_date,
            'sortOrder', p.sort_order,
            'isFeatured', p.is_featured,
            'isNewMembersOnly', p.is_new_members_only,
            'isActive', p.is_active,
            'createdAt', p.created_at,
            'updatedAt', p.updated_at,
            -- İlk banner (thumbnail için)
            'thumbnail', (
                SELECT pb.image_url
                FROM content.promotion_banners pb
                WHERE pb.promotion_id = p.id AND pb.is_active = TRUE
                ORDER BY pb.sort_order, pb.id
                LIMIT 1
            )
        ) ORDER BY p.sort_order, p.created_at DESC
    ), '[]'::jsonb)
    INTO v_items
    FROM (
        SELECT * FROM content.promotions
        WHERE (p_promotion_type_id IS NULL OR promotion_type_id = p_promotion_type_id)
          AND (p_is_active IS NULL OR is_active = p_is_active)
          AND (p_is_featured IS NULL OR is_featured = p_is_featured)
          AND (p_search IS NULL OR code ILIKE '%' || p_search || '%')
        ORDER BY sort_order, created_at DESC
        LIMIT p_page_size OFFSET v_offset
    ) p
    LEFT JOIN content.promotion_types pt ON pt.id = p.promotion_type_id
    LEFT JOIN content.promotion_type_translations ptt ON ptt.promotion_type_id = pt.id AND ptt.language_code = 'en';

    RETURN jsonb_build_object(
        'items', v_items,
        'totalCount', v_total_count,
        'page', p_page,
        'pageSize', p_page_size
    );
END;
$$;

COMMENT ON FUNCTION content.promotion_list IS 'Lists promotions for backoffice. Auth check done in Core DB.';
