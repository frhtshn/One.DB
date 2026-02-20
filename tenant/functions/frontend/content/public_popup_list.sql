-- ================================================================
-- PUBLIC_POPUP_LIST: Aktif popup'lar (FE)
-- Sayfa URL + ülke + segment filtrelemeli
-- Zamanlama ve hedefleme kontrolü
-- ================================================================

DROP FUNCTION IF EXISTS content.public_popup_list(TEXT, CHAR, INTEGER[], CHAR, VARCHAR);

CREATE OR REPLACE FUNCTION content.public_popup_list(
    p_page_url          TEXT        DEFAULT NULL,    -- Sayfa URL filtresi
    p_country_code      CHAR(2)     DEFAULT NULL,    -- Oyuncu ülkesi
    p_segment_ids       INTEGER[]   DEFAULT NULL,    -- Oyuncu segmentleri
    p_language_code     CHAR(2)     DEFAULT 'en',    -- Dil kodu
    p_device_type       VARCHAR(20) DEFAULT NULL     -- desktop, mobile, tablet
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'id', p.id,
        'code', p.code,
        'popupTypeCode', pt.code,
        'width', COALESCE(p.width, pt.default_width),
        'height', COALESCE(p.height, pt.default_height),
        'hasOverlay', pt.has_overlay,
        'canClose', pt.can_close,
        'closeOnOverlayClick', pt.close_on_overlay_click,
        'triggerType', p.trigger_type,
        'triggerDelay', p.trigger_delay,
        'triggerScrollPercent', p.trigger_scroll_percent,
        'triggerExitIntent', p.trigger_exit_intent,
        'frequencyType', p.frequency_type,
        'frequencyCap', p.frequency_cap,
        'frequencyHours', p.frequency_hours,
        'displayDuration', p.display_duration,
        'autoClose', p.auto_close,
        'linkUrl', p.link_url,
        'linkTarget', p.link_target,
        'priority', p.priority,
        'title', t.title,
        'subtitle', t.subtitle,
        'bodyText', t.body_text,
        'ctaText', t.cta_text,
        'ctaSecondaryText', t.cta_secondary_text,
        'closeButtonText', t.close_button_text,
        'images', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'imagePosition', i.image_position,
                'imageUrl', i.image_url,
                'imageUrl2x', i.image_url_2x,
                'imageUrlWebp', i.image_url_webp,
                'width', i.width, 'height', i.height,
                'objectFit', i.object_fit, 'borderRadius', i.border_radius
            ) ORDER BY i.sort_order)
            FROM content.popup_images i
            WHERE i.popup_id = p.id AND i.is_active = TRUE
              AND (i.language_code IS NULL OR i.language_code = p_language_code)
              AND (p_device_type IS NULL OR i.device_type = p_device_type OR i.device_type = 'desktop')
        ), '[]'::JSONB)
    ) ORDER BY p.priority DESC), '[]'::JSONB)
    INTO v_result
    FROM content.popups p
    INNER JOIN content.popup_types pt ON pt.id = p.popup_type_id
    LEFT JOIN content.popup_translations t
        ON t.popup_id = p.id AND t.language_code = p_language_code
    LEFT JOIN content.popup_schedules s
        ON s.popup_id = p.id AND s.is_active = TRUE
    WHERE p.is_active = TRUE AND p.is_deleted = FALSE
      -- Tarih kontrolü
      AND (p.start_date IS NULL OR p.start_date <= NOW())
      AND (p.end_date IS NULL OR p.end_date > NOW())
      -- Ülke kontrolü
      AND (p.country_codes IS NULL OR p_country_code = ANY(p.country_codes))
      AND (p.excluded_country_codes IS NULL OR NOT (p_country_code = ANY(p.excluded_country_codes)))
      -- Segment kontrolü
      AND (p.segment_ids IS NULL OR p.segment_ids && p_segment_ids)
      -- Sayfa URL kontrolü
      AND (p.page_urls IS NULL OR p_page_url = ANY(p.page_urls))
      AND (p.excluded_page_urls IS NULL OR NOT (p_page_url = ANY(p.excluded_page_urls)))
      -- Zamanlama kontrolü (gün)
      AND (s.id IS NULL OR (
          CASE EXTRACT(DOW FROM NOW())
              WHEN 0 THEN s.day_sunday
              WHEN 1 THEN s.day_monday
              WHEN 2 THEN s.day_tuesday
              WHEN 3 THEN s.day_wednesday
              WHEN 4 THEN s.day_thursday
              WHEN 5 THEN s.day_friday
              WHEN 6 THEN s.day_saturday
          END = TRUE
          AND (s.start_time IS NULL OR NOW()::TIME >= s.start_time)
          AND (s.end_time IS NULL OR NOW()::TIME <= s.end_time)
      ));

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION content.public_popup_list(TEXT, CHAR, INTEGER[], CHAR, VARCHAR) IS 'Get active popups for frontend rendering with country, segment, page URL, and schedule filtering.';
