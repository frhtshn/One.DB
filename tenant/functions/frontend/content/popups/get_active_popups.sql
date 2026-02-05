-- ================================================================
-- GET_ACTIVE_POPUPS: Aktif popup'ları getir (Frontend)
-- ================================================================
-- Public content - yetki kontrolü gerekmez.
-- Tarih, ülke ve segment filtrelemesi yapar.
-- Sayfa URL'sine göre de filtreleme yapar.
-- ================================================================

DROP FUNCTION IF EXISTS content.get_active_popups(VARCHAR, CHAR(2), CHAR(2), INTEGER[], TEXT);

CREATE OR REPLACE FUNCTION content.get_active_popups(
    p_trigger_type VARCHAR(30) DEFAULT NULL,   -- Tetikleme türüne göre filtre (NULL = tümü)
    p_language CHAR(2) DEFAULT 'en',           -- İçerik dili
    p_country_code CHAR(2) DEFAULT NULL,       -- Kullanıcı ülkesi
    p_segment_ids INTEGER[] DEFAULT NULL,      -- Kullanıcı segment'leri
    p_page_url TEXT DEFAULT NULL               -- Mevcut sayfa URL'i
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
                'popupTypeCode', pt.code,
                -- Görüntüleme
                'displayDuration', p.display_duration,
                'autoClose', p.auto_close,
                'width', COALESCE(p.width, pt.default_width),
                'height', COALESCE(p.height, pt.default_height),
                'hasOverlay', pt.has_overlay,
                'canClose', pt.can_close,
                'closeOnOverlayClick', pt.close_on_overlay_click,
                -- Tetikleyici
                'triggerType', p.trigger_type,
                'triggerDelay', p.trigger_delay,
                'triggerScrollPercent', p.trigger_scroll_percent,
                'triggerExitIntent', p.trigger_exit_intent,
                -- Sıklık
                'frequencyType', p.frequency_type,
                'frequencyCap', p.frequency_cap,
                'frequencyHours', p.frequency_hours,
                -- Link
                'linkUrl', p.link_url,
                'linkTarget', p.link_target,
                -- Öncelik
                'priority', p.priority,
                -- Çeviri (istenen dil veya fallback)
                'title', COALESCE(t.title, t_def.title),
                'subtitle', COALESCE(t.subtitle, t_def.subtitle),
                'bodyText', COALESCE(t.body_text, t_def.body_text),
                'ctaText', COALESCE(t.cta_text, t_def.cta_text),
                'ctaSecondaryText', COALESCE(t.cta_secondary_text, t_def.cta_secondary_text),
                'closeButtonText', COALESCE(t.close_button_text, t_def.close_button_text),
                -- Görseller (aktif, cihaza göre gruplu)
                'images', COALESCE((
                    SELECT jsonb_agg(jsonb_build_object(
                        'deviceType', i.device_type,
                        'imagePosition', i.image_position,
                        'imageUrl', i.image_url,
                        'imageUrl2x', i.image_url_2x,
                        'imageUrlWebp', i.image_url_webp,
                        'width', i.width,
                        'height', i.height,
                        'objectFit', i.object_fit
                    ) ORDER BY i.sort_order)
                    FROM content.popup_images i
                    WHERE i.popup_id = p.id
                      AND i.is_active = TRUE
                      AND (i.language_code IS NULL OR i.language_code = p_language)
                ), '[]'::jsonb)
            ) ORDER BY p.priority DESC
        )
        FROM content.popups p
        JOIN content.popup_types pt ON pt.id = p.popup_type_id AND pt.is_active = TRUE
        -- İstenen dil çevirisi
        LEFT JOIN content.popup_translations t
            ON t.popup_id = p.id AND t.language_code = p_language
        -- Default dil (en) fallback
        LEFT JOIN content.popup_translations t_def
            ON t_def.popup_id = p.id AND t_def.language_code = 'en'
        WHERE p.is_active = TRUE
          AND p.is_deleted = FALSE
          -- Trigger type filtresi
          AND (p_trigger_type IS NULL OR p.trigger_type = p_trigger_type)
          -- Tarih filtresi
          AND (p.start_date IS NULL OR p.start_date <= v_now)
          AND (p.end_date IS NULL OR p.end_date >= v_now)
          -- Ülke filtresi (hedef listede veya liste boş)
          AND (
              p.country_codes IS NULL
              OR ARRAY_LENGTH(p.country_codes, 1) IS NULL
              OR p_country_code = ANY(p.country_codes)
          )
          -- Hariç tutulan ülke filtresi
          AND (
              p.excluded_country_codes IS NULL
              OR ARRAY_LENGTH(p.excluded_country_codes, 1) IS NULL
              OR p_country_code IS NULL
              OR NOT (p_country_code = ANY(p.excluded_country_codes))
          )
          -- Segment filtresi (en az bir segment eşleşmeli veya segment tanımlı değil)
          AND (
              p.segment_ids IS NULL
              OR ARRAY_LENGTH(p.segment_ids, 1) IS NULL
              OR p_segment_ids IS NULL
              OR p.segment_ids && p_segment_ids
          )
          -- Sayfa URL filtresi
          AND (
              p.page_urls IS NULL
              OR ARRAY_LENGTH(p.page_urls, 1) IS NULL
              OR p_page_url IS NULL
              OR EXISTS (
                  SELECT 1 FROM unnest(p.page_urls) AS allowed_url
                  WHERE p_page_url LIKE allowed_url
              )
          )
          -- Hariç tutulan sayfa URL filtresi
          AND (
              p.excluded_page_urls IS NULL
              OR ARRAY_LENGTH(p.excluded_page_urls, 1) IS NULL
              OR p_page_url IS NULL
              OR NOT EXISTS (
                  SELECT 1 FROM unnest(p.excluded_page_urls) AS excluded_url
                  WHERE p_page_url LIKE excluded_url
              )
          )
    ), '[]'::jsonb);
END;
$$;

COMMENT ON FUNCTION content.get_active_popups IS
'Returns active popups for frontend with targeting filters.
No auth required (public content).
Filters: trigger_type, date range, country, segments, page URL.
Returns popup config with type settings, translations, and images.';
