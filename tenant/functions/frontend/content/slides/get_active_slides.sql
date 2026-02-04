-- ================================================================
-- GET_ACTIVE_SLIDES: Frontend için aktif slide'ları getir
-- ================================================================
-- Consumer function - Frontend uygulaması için
-- Hedefleme, tarih ve segment filtreleme uygular
-- Yetki kontrolü GEREKMEZ (public içerik)
-- ================================================================

DROP FUNCTION IF EXISTS content.get_active_slides(VARCHAR, CHAR(2), CHAR(2), INTEGER[]);

CREATE OR REPLACE FUNCTION content.get_active_slides(
    p_placement_code VARCHAR(50),          -- Gösterim alanı kodu (hero, sidebar, vb.)
    p_language CHAR(2) DEFAULT 'en',       -- Dil kodu
    p_country_code CHAR(2) DEFAULT NULL,   -- Kullanıcı ülkesi (hedefleme için)
    p_segment_ids INTEGER[] DEFAULT NULL   -- Kullanıcı segment'leri (hedefleme için)
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_placement_id INTEGER;
    v_now TIMESTAMP := NOW();
BEGIN
    -- Placement ID bul
    SELECT id INTO v_placement_id
    FROM content.slide_placements
    WHERE code = p_placement_code AND is_active = TRUE;

    IF v_placement_id IS NULL THEN
        RETURN '[]'::jsonb;
    END IF;

    -- Aktif slide'ları getir
    RETURN COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'id', s.id,
                'code', s.code,
                -- Çeviri (fallback: en)
                'title', COALESCE(st.title, st_en.title),
                'subtitle', COALESCE(st.subtitle, st_en.subtitle),
                'buttonText', COALESCE(st.button_text, st_en.button_text),
                -- Link
                'linkUrl', s.link_url,
                'linkTarget', s.link_target,
                'linkType', s.link_type,
                'linkReference', s.link_reference,
                -- Resim (dile göre veya default)
                'imageUrl', COALESCE(
                    (SELECT si.image_url FROM content.slide_images si
                     WHERE si.slide_id = s.id AND si.language_code = p_language LIMIT 1),
                    (SELECT si.image_url FROM content.slide_images si
                     WHERE si.slide_id = s.id AND si.is_default = TRUE LIMIT 1),
                    (SELECT si.image_url FROM content.slide_images si
                     WHERE si.slide_id = s.id ORDER BY si.id LIMIT 1)
                ),
                'mobileImageUrl', COALESCE(
                    (SELECT si.mobile_image_url FROM content.slide_images si
                     WHERE si.slide_id = s.id AND si.language_code = p_language LIMIT 1),
                    (SELECT si.mobile_image_url FROM content.slide_images si
                     WHERE si.slide_id = s.id AND si.is_default = TRUE LIMIT 1)
                ),
                'altText', COALESCE(
                    (SELECT si.alt_text FROM content.slide_images si
                     WHERE si.slide_id = s.id AND si.language_code = p_language LIMIT 1),
                    (SELECT si.alt_text FROM content.slide_images si
                     WHERE si.slide_id = s.id AND si.is_default = TRUE LIMIT 1)
                ),
                -- Görüntüleme
                'displayDuration', s.display_duration,
                'animationType', s.animation_type
            ) ORDER BY s.sort_order, s.priority DESC
        )
        FROM content.slides s
        LEFT JOIN content.slide_translations st ON st.slide_id = s.id AND st.language_code = p_language
        LEFT JOIN content.slide_translations st_en ON st_en.slide_id = s.id AND st_en.language_code = 'en'
        WHERE s.placement_id = v_placement_id
          AND s.is_active = TRUE
          AND s.is_deleted = FALSE
          -- Tarih filtresi
          AND (s.start_date IS NULL OR s.start_date <= v_now)
          AND (s.end_date IS NULL OR s.end_date >= v_now)
          -- Ülke hedefleme
          AND (s.country_codes IS NULL OR p_country_code = ANY(s.country_codes))
          AND (s.excluded_country_codes IS NULL OR NOT (p_country_code = ANY(s.excluded_country_codes)))
          -- Segment hedefleme
          AND (s.segment_ids IS NULL OR s.segment_ids && p_segment_ids OR p_segment_ids IS NULL)
    ), '[]'::jsonb);
END;
$$;

COMMENT ON FUNCTION content.get_active_slides IS
'Returns active slides for frontend rendering.
Applies date, country, and segment filtering.
No auth required (public content).
Usage: SELECT content.get_active_slides(''hero'', ''tr'', ''TR'', ARRAY[1,2])';
