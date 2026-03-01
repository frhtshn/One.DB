-- ================================================================
-- PUBLIC_SLIDE_LIST: Aktif slide'lar (FE)
-- Placement kodu + ülke + segment + cihaz filtrelemeli
-- Zamanlama kontrolü dahil
-- max_slides limiti uygulanır
-- ================================================================

DROP FUNCTION IF EXISTS content.public_slide_list(VARCHAR, CHAR, CHAR, INTEGER[], VARCHAR);

CREATE OR REPLACE FUNCTION content.public_slide_list(
    p_placement_code    VARCHAR(50),        -- Yerleşim kodu (ör. homepage_hero)
    p_language_code     CHAR(2)     DEFAULT 'en',
    p_country_code      CHAR(2)     DEFAULT NULL,
    p_segment_ids       INTEGER[]   DEFAULT NULL,
    p_device_type       VARCHAR(20) DEFAULT NULL     -- desktop, mobile, tablet
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
    v_max_slides INTEGER;
BEGIN
    IF p_placement_code IS NULL OR p_placement_code = '' THEN
        RETURN '[]'::JSONB;
    END IF;

    -- Max slides limiti
    SELECT sp.max_slides INTO v_max_slides
    FROM content.slide_placements sp
    WHERE sp.code = p_placement_code AND sp.is_active = TRUE;

    IF v_max_slides IS NULL THEN
        RETURN '[]'::JSONB;
    END IF;

    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'id', s.id, 'code', s.code,
        'linkUrl', s.link_url, 'linkTarget', s.link_target,
        'linkType', s.link_type, 'linkReference', s.link_reference,
        'displayDuration', s.display_duration, 'animationType', s.animation_type,
        'title', t.title, 'subtitle', t.subtitle,
        'description', t.description, 'ctaText', t.cta_text,
        'ctaSecondaryText', t.cta_secondary_text, 'altText', t.alt_text,
        'images', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'imageUrl', i.image_url, 'imageUrl2x', i.image_url_2x,
                'imageUrlWebp', i.image_url_webp,
                'width', i.width, 'height', i.height, 'fallbackColor', i.fallback_color
            ) ORDER BY i.sort_order)
            FROM content.slide_images i
            WHERE i.slide_id = s.id AND i.is_active = TRUE
              AND (i.language_code IS NULL OR i.language_code = p_language_code)
              AND (p_device_type IS NULL OR i.device_type = p_device_type OR i.device_type = 'desktop')
        ), '[]'::JSONB)
    ) ORDER BY s.sort_order), '[]'::JSONB)
    INTO v_result
    FROM content.slides s
    INNER JOIN content.slide_placements sp ON sp.id = s.placement_id
    LEFT JOIN content.slide_translations t
        ON t.slide_id = s.id AND t.language_code = p_language_code
    LEFT JOIN content.slide_schedules sc
        ON sc.slide_id = s.id AND sc.is_active = TRUE
    WHERE sp.code = p_placement_code
      AND s.is_active = TRUE AND s.is_deleted = FALSE
      -- Tarih kontrolü
      AND (s.start_date IS NULL OR s.start_date <= NOW())
      AND (s.end_date IS NULL OR s.end_date > NOW())
      -- Ülke kontrolü
      AND (s.country_codes IS NULL OR p_country_code = ANY(s.country_codes))
      AND (s.excluded_country_codes IS NULL OR NOT (p_country_code = ANY(s.excluded_country_codes)))
      -- Segment kontrolü
      AND (s.segment_ids IS NULL OR s.segment_ids && p_segment_ids)
      -- Zamanlama kontrolü
      AND (sc.id IS NULL OR (
          CASE EXTRACT(DOW FROM NOW())
              WHEN 0 THEN sc.day_sunday WHEN 1 THEN sc.day_monday
              WHEN 2 THEN sc.day_tuesday WHEN 3 THEN sc.day_wednesday
              WHEN 4 THEN sc.day_thursday WHEN 5 THEN sc.day_friday
              WHEN 6 THEN sc.day_saturday
          END = TRUE
          AND (sc.start_time IS NULL OR NOW()::TIME >= sc.start_time)
          AND (sc.end_time IS NULL OR NOW()::TIME <= sc.end_time)
      ))
    ORDER BY s.sort_order
    LIMIT v_max_slides;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION content.public_slide_list(VARCHAR, CHAR, CHAR, INTEGER[], VARCHAR) IS 'Get active slides for a placement. Applies country, segment, schedule, and max_slides filters.';
