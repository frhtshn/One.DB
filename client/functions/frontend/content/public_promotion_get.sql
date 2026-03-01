-- ================================================================
-- PUBLIC_PROMOTION_GET: Tek promosyon detayı (FE)
-- Aktif, yayında, süresi dolmamış kontrolü
-- ================================================================

DROP FUNCTION IF EXISTS content.public_promotion_get(INTEGER, CHAR);

CREATE OR REPLACE FUNCTION content.public_promotion_get(
    p_id                INTEGER,
    p_language_code     CHAR(2) DEFAULT 'en'
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'id', p.id, 'code', p.code,
        'typeCode', pt.code, 'typeIcon', pt.icon, 'typeColor', pt.color,
        'typeBadgeText', pt.badge_text,
        'bonusId', p.bonus_id,
        'minDeposit', p.min_deposit, 'maxDeposit', p.max_deposit,
        'startDate', p.start_date, 'endDate', p.end_date,
        'isFeatured', p.is_featured, 'isNewMembersOnly', p.is_new_members_only,
        'title', t.title, 'subtitle', t.subtitle, 'summary', t.summary,
        'description', t.description, 'termsConditions', t.terms_conditions,
        'ctaText', t.cta_text, 'ctaUrl', t.cta_url,
        'metaTitle', t.meta_title, 'metaDescription', t.meta_description,
        'banners', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'deviceType', b.device_type, 'imageUrl', b.image_url,
                'altText', b.alt_text, 'width', b.width, 'height', b.height
            ) ORDER BY b.sort_order)
            FROM content.promotion_banners b
            WHERE b.promotion_id = p.id AND b.is_active = TRUE
              AND (b.language_code IS NULL OR b.language_code = p_language_code)
        ), '[]'::JSONB)
    ) INTO v_result
    FROM content.promotions p
    INNER JOIN content.promotion_types pt ON pt.id = p.promotion_type_id
    LEFT JOIN content.promotion_translations t
        ON t.promotion_id = p.id AND t.language_code = p_language_code
    WHERE p.id = p_id AND p.is_active = TRUE
      AND (p.start_date IS NULL OR p.start_date <= NOW())
      AND (p.end_date IS NULL OR p.end_date > NOW());

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION content.public_promotion_get(INTEGER, CHAR) IS 'Get single promotion detail for frontend. Returns NULL if not found, inactive, or expired.';
