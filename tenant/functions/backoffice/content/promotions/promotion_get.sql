-- ================================================================
-- PROMOTION_GET: Tek promosyon detayı (Backoffice)
-- ================================================================
-- NOT: Yetki kontrolü Core DB'de yapılır (user_assert_access_tenant)
-- Translations ve banners dahil döner.
-- ================================================================

DROP FUNCTION IF EXISTS content.promotion_get(INTEGER);

CREATE OR REPLACE FUNCTION content.promotion_get(
    p_id INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
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
        'createdBy', p.created_by,
        'updatedAt', p.updated_at,
        'updatedBy', p.updated_by,
        -- Translations
        'translations', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'id', t.id,
                'languageCode', t.language_code,
                'title', t.title,
                'subtitle', t.subtitle,
                'summary', t.summary,
                'description', t.description,
                'termsConditions', t.terms_conditions,
                'ctaText', t.cta_text,
                'ctaUrl', t.cta_url,
                'metaTitle', t.meta_title,
                'metaDescription', t.meta_description,
                'status', t.status
            ) ORDER BY t.language_code)
            FROM content.promotion_translations t
            WHERE t.promotion_id = p.id
        ), '[]'::jsonb),
        -- Banners
        'banners', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'id', b.id,
                'languageCode', b.language_code,
                'deviceType', b.device_type,
                'imageUrl', b.image_url,
                'altText', b.alt_text,
                'width', b.width,
                'height', b.height,
                'sortOrder', b.sort_order,
                'isActive', b.is_active
            ) ORDER BY b.sort_order, b.device_type)
            FROM content.promotion_banners b
            WHERE b.promotion_id = p.id
        ), '[]'::jsonb)
    )
    INTO v_result
    FROM content.promotions p
    LEFT JOIN content.promotion_types pt ON pt.id = p.promotion_type_id
    LEFT JOIN content.promotion_type_translations ptt ON ptt.promotion_type_id = pt.id AND ptt.language_code = 'en'
    WHERE p.id = p_id;

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.promotion.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION content.promotion_get IS 'Returns single promotion with translations and banners. Auth check done in Core DB.';
