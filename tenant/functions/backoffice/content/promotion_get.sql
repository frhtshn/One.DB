-- ================================================================
-- PROMOTION_GET: Promosyon detay getir
-- Tüm ilişkili veriler dahil
-- ================================================================

DROP FUNCTION IF EXISTS content.promotion_get(INTEGER);

CREATE OR REPLACE FUNCTION content.promotion_get(
    p_id                INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    IF p_id IS NULL THEN RAISE EXCEPTION 'error.promotion.id-required'; END IF;

    SELECT jsonb_build_object(
        'id', p.id, 'code', p.code, 'promotionTypeId', p.promotion_type_id,
        'bonusId', p.bonus_id, 'minDeposit', p.min_deposit, 'maxDeposit', p.max_deposit,
        'startDate', p.start_date, 'endDate', p.end_date, 'sortOrder', p.sort_order,
        'isFeatured', p.is_featured, 'isNewMembersOnly', p.is_new_members_only,
        'isActive', p.is_active, 'createdAt', p.created_at, 'updatedAt', p.updated_at,
        'translations', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'id', t.id, 'languageCode', t.language_code, 'title', t.title,
                'subtitle', t.subtitle, 'summary', t.summary, 'description', t.description,
                'termsConditions', t.terms_conditions, 'ctaText', t.cta_text, 'ctaUrl', t.cta_url,
                'metaTitle', t.meta_title, 'metaDescription', t.meta_description, 'status', t.status
            ) ORDER BY t.language_code)
            FROM content.promotion_translations t WHERE t.promotion_id = p.id
        ), '[]'::JSONB),
        'banners', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'id', b.id, 'languageCode', b.language_code, 'deviceType', b.device_type,
                'imageUrl', b.image_url, 'altText', b.alt_text, 'width', b.width, 'height', b.height
            ) ORDER BY b.sort_order)
            FROM content.promotion_banners b WHERE b.promotion_id = p.id AND b.is_active = TRUE
        ), '[]'::JSONB),
        'segments', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'id', s.id, 'segmentType', s.segment_type,
                'segmentValue', s.segment_value, 'isInclude', s.is_include
            ))
            FROM content.promotion_segments s WHERE s.promotion_id = p.id
        ), '[]'::JSONB),
        'games', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'id', g.id, 'filterType', g.filter_type,
                'filterValue', g.filter_value, 'isInclude', g.is_include
            ))
            FROM content.promotion_games g WHERE g.promotion_id = p.id
        ), '[]'::JSONB),
        'displayLocations', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'id', dl.id, 'locationCode', dl.location_code, 'sortOrder', dl.sort_order
            ) ORDER BY dl.sort_order)
            FROM content.promotion_display_locations dl WHERE dl.promotion_id = p.id AND dl.is_active = TRUE
        ), '[]'::JSONB)
    ) INTO v_result
    FROM content.promotions p
    WHERE p.id = p_id AND p.is_active = TRUE;

    IF v_result IS NULL THEN RAISE EXCEPTION 'error.promotion.not-found'; END IF;
    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION content.promotion_get(INTEGER) IS 'Get promotion detail with translations, banners, segments, games, and display locations.';
