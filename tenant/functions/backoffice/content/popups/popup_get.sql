-- ================================================================
-- POPUP_GET: Popup detay (Backoffice)
-- ================================================================
-- NOT: Yetki kontrolü Core DB'de yapılır (user_assert_access_tenant)
-- Bu function sadece iş mantığını içerir.
-- ================================================================

DROP FUNCTION IF EXISTS content.popup_get(INTEGER);

CREATE OR REPLACE FUNCTION content.popup_get(
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
        'popupTypeId', p.popup_type_id,
        'popupTypeCode', pt.code,
        -- Görüntüleme
        'displayDuration', p.display_duration,
        'autoClose', p.auto_close,
        'width', p.width,
        'height', p.height,
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
        -- Tarihler
        'startDate', p.start_date,
        'endDate', p.end_date,
        -- Hedefleme
        'segmentIds', p.segment_ids,
        'countryCodes', p.country_codes,
        'excludedCountryCodes', p.excluded_country_codes,
        'pageUrls', p.page_urls,
        'excludedPageUrls', p.excluded_page_urls,
        -- Öncelik ve durum
        'priority', p.priority,
        'isActive', p.is_active,
        -- Audit
        'createdAt', p.created_at,
        'createdBy', p.created_by,
        'updatedAt', p.updated_at,
        'updatedBy', p.updated_by,
        -- Translations
        'translations', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'languageCode', t.language_code,
                'title', t.title,
                'subtitle', t.subtitle,
                'bodyText', t.body_text,
                'ctaText', t.cta_text,
                'ctaSecondaryText', t.cta_secondary_text,
                'closeButtonText', t.close_button_text
            ) ORDER BY t.language_code)
            FROM content.popup_translations t
            WHERE t.popup_id = p.id
        ), '[]'::jsonb),
        -- Images
        'images', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'id', i.id,
                'languageCode', i.language_code,
                'deviceType', i.device_type,
                'imagePosition', i.image_position,
                'imageUrl', i.image_url,
                'imageUrl2x', i.image_url_2x,
                'imageUrlWebp', i.image_url_webp,
                'width', i.width,
                'height', i.height,
                'objectFit', i.object_fit,
                'sortOrder', i.sort_order,
                'isActive', i.is_active
            ) ORDER BY i.sort_order, i.device_type)
            FROM content.popup_images i
            WHERE i.popup_id = p.id
        ), '[]'::jsonb)
    )
    INTO v_result
    FROM content.popups p
    LEFT JOIN content.popup_types pt ON pt.id = p.popup_type_id
    WHERE p.id = p_id AND p.is_deleted = FALSE;

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.popup.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION content.popup_get IS 'Returns popup detail with translations and images. Auth check done in Core DB.';
