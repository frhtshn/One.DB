-- ================================================================
-- GET_ACTIVE_PROMOTIONS: Aktif promosyonları getir (Frontend)
-- ================================================================
-- Public content - yetki kontrolü gerekmez.
-- Tarih filtrelemesi yapar.
-- Dil bazlı çeviriler ve bannerlar dahil döner.
-- ================================================================

DROP FUNCTION IF EXISTS content.get_active_promotions(VARCHAR, CHAR(2), BOOLEAN);

CREATE OR REPLACE FUNCTION content.get_active_promotions(
    p_type_code VARCHAR(50) DEFAULT NULL,     -- Promosyon tip koduna göre filtre (NULL = tümü)
    p_language CHAR(2) DEFAULT 'en',          -- İçerik dili
    p_featured_only BOOLEAN DEFAULT FALSE     -- Sadece öne çıkanlar
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_now TIMESTAMP := NOW();
BEGIN
    RETURN COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'id', p.id,
                'code', p.code,
                'typeCode', pt.code,
                'typeIcon', pt.icon,
                'typeColor', pt.color,
                'typeBadge', pt.badge_text,
                'minDeposit', p.min_deposit,
                'maxDeposit', p.max_deposit,
                'startDate', p.start_date,
                'endDate', p.end_date,
                'isFeatured', p.is_featured,
                'isNewMembersOnly', p.is_new_members_only,
                -- Çeviri (istenen dil veya fallback)
                'title', COALESCE(t.title, t_def.title),
                'subtitle', COALESCE(t.subtitle, t_def.subtitle),
                'summary', COALESCE(t.summary, t_def.summary),
                'description', COALESCE(t.description, t_def.description),
                'termsConditions', COALESCE(t.terms_conditions, t_def.terms_conditions),
                'ctaText', COALESCE(t.cta_text, t_def.cta_text),
                'ctaUrl', COALESCE(t.cta_url, t_def.cta_url),
                'metaTitle', COALESCE(t.meta_title, t_def.meta_title),
                'metaDescription', COALESCE(t.meta_description, t_def.meta_description),
                -- Banner (dile ve cihaza göre)
                'banners', COALESCE((
                    SELECT jsonb_agg(jsonb_build_object(
                        'deviceType', b.device_type,
                        'imageUrl', b.image_url,
                        'altText', b.alt_text,
                        'width', b.width,
                        'height', b.height
                    ) ORDER BY b.sort_order, b.device_type)
                    FROM content.promotion_banners b
                    WHERE b.promotion_id = p.id
                      AND b.is_active = TRUE
                      AND (b.language_code IS NULL OR b.language_code = p_language)
                ), '[]'::jsonb)
            ) ORDER BY p.sort_order, p.created_at DESC
        )
        FROM content.promotions p
        JOIN content.promotion_types pt ON pt.id = p.promotion_type_id AND pt.is_active = TRUE
        -- İstenen dil çevirisi
        LEFT JOIN content.promotion_translations t
            ON t.promotion_id = p.id AND t.language_code = p_language AND t.status = 'published'
        -- Default dil (en) fallback
        LEFT JOIN content.promotion_translations t_def
            ON t_def.promotion_id = p.id AND t_def.language_code = 'en' AND t_def.status = 'published'
        WHERE p.is_active = TRUE
          -- Type code filtresi
          AND (p_type_code IS NULL OR pt.code = p_type_code)
          -- Featured filtresi
          AND (p_featured_only = FALSE OR p.is_featured = TRUE)
          -- Tarih filtresi
          AND (p.start_date IS NULL OR p.start_date <= v_now)
          AND (p.end_date IS NULL OR p.end_date >= v_now)
          -- En az bir çeviri olmalı
          AND (t.id IS NOT NULL OR t_def.id IS NOT NULL)
    ), '[]'::jsonb);
END;
$$;

COMMENT ON FUNCTION content.get_active_promotions IS
'Returns active promotions for frontend with translations and banners.
No auth required (public content).
Filters: type_code, featured_only, date range.
Usage: SELECT content.get_active_promotions(''welcome'', ''tr'', FALSE)';
