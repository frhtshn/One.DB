-- ================================================================
-- PUBLIC_PROMOTION_LIST: Aktif promosyonlar (FE)
-- Segment + ülke filtrelemeli
-- ================================================================

DROP FUNCTION IF EXISTS content.public_promotion_list(CHAR, VARCHAR, INTEGER[], INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION content.public_promotion_list(
    p_language_code     CHAR(2)     DEFAULT 'en',
    p_type_code         VARCHAR(50) DEFAULT NULL,   -- Tip filtresi
    p_segment_ids       INTEGER[]   DEFAULT NULL,   -- Oyuncu segmentleri (basit filtre)
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
    INNER JOIN content.promotion_types pt ON pt.id = p.promotion_type_id
    WHERE p.is_active = TRUE
      AND (p.start_date IS NULL OR p.start_date <= NOW())
      AND (p.end_date IS NULL OR p.end_date > NOW())
      AND (p_type_code IS NULL OR pt.code = p_type_code);

    SELECT COALESCE(jsonb_agg(row_data ORDER BY is_featured DESC, sort_order), '[]'::JSONB)
    INTO v_items
    FROM (
        SELECT jsonb_build_object(
            'id', p.id, 'code', p.code,
            'typeCode', pt.code, 'typeIcon', pt.icon, 'typeColor', pt.color,
            'bonusId', p.bonus_id,
            'minDeposit', p.min_deposit, 'maxDeposit', p.max_deposit,
            'startDate', p.start_date, 'endDate', p.end_date,
            'isFeatured', p.is_featured, 'isNewMembersOnly', p.is_new_members_only,
            'title', t.title, 'subtitle', t.subtitle, 'summary', t.summary,
            'ctaText', t.cta_text, 'ctaUrl', t.cta_url,
            'banners', COALESCE((
                SELECT jsonb_agg(jsonb_build_object(
                    'deviceType', b.device_type, 'imageUrl', b.image_url,
                    'altText', b.alt_text, 'width', b.width, 'height', b.height
                ) ORDER BY b.sort_order)
                FROM content.promotion_banners b
                WHERE b.promotion_id = p.id AND b.is_active = TRUE
                  AND (b.language_code IS NULL OR b.language_code = p_language_code)
            ), '[]'::JSONB)
        ) AS row_data, p.is_featured, p.sort_order
        FROM content.promotions p
        INNER JOIN content.promotion_types pt ON pt.id = p.promotion_type_id
        LEFT JOIN content.promotion_translations t
            ON t.promotion_id = p.id AND t.language_code = p_language_code
        WHERE p.is_active = TRUE
          AND (p.start_date IS NULL OR p.start_date <= NOW())
          AND (p.end_date IS NULL OR p.end_date > NOW())
          AND (p_type_code IS NULL OR pt.code = p_type_code)
        ORDER BY p.is_featured DESC, p.sort_order
        OFFSET p_offset LIMIT p_limit
    ) sub;

    RETURN jsonb_build_object('items', v_items, 'totalCount', v_total_count);
END;
$$;

COMMENT ON FUNCTION content.public_promotion_list(CHAR, VARCHAR, INTEGER[], INTEGER, INTEGER) IS 'List active promotions for frontend with type filter. Only shows published, non-expired promotions.';
