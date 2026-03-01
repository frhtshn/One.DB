-- ================================================================
-- POPUP_GET: Popup detay getir
-- Tüm ilişkili veriler dahil
-- ================================================================

DROP FUNCTION IF EXISTS content.popup_get(INTEGER);

CREATE OR REPLACE FUNCTION content.popup_get(
    p_id                INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    IF p_id IS NULL THEN
        RAISE EXCEPTION 'error.popup.id-required';
    END IF;

    SELECT jsonb_build_object(
        'id', p.id,
        'popupTypeId', p.popup_type_id,
        'code', p.code,
        'displayDuration', p.display_duration,
        'autoClose', p.auto_close,
        'width', p.width,
        'height', p.height,
        'triggerType', p.trigger_type,
        'triggerDelay', p.trigger_delay,
        'triggerScrollPercent', p.trigger_scroll_percent,
        'triggerExitIntent', p.trigger_exit_intent,
        'frequencyType', p.frequency_type,
        'frequencyCap', p.frequency_cap,
        'frequencyHours', p.frequency_hours,
        'linkUrl', p.link_url,
        'linkTarget', p.link_target,
        'startDate', p.start_date,
        'endDate', p.end_date,
        'priority', p.priority,
        'segmentIds', p.segment_ids,
        'countryCodes', p.country_codes,
        'excludedCountryCodes', p.excluded_country_codes,
        'pageUrls', p.page_urls,
        'excludedPageUrls', p.excluded_page_urls,
        'isActive', p.is_active,
        'createdAt', p.created_at,
        'updatedAt', p.updated_at,
        'translations', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'id', t.id, 'languageCode', t.language_code,
                'title', t.title, 'subtitle', t.subtitle, 'bodyText', t.body_text,
                'ctaText', t.cta_text, 'ctaSecondaryText', t.cta_secondary_text,
                'closeButtonText', t.close_button_text
            ) ORDER BY t.language_code)
            FROM content.popup_translations t WHERE t.popup_id = p.id
        ), '[]'::JSONB),
        'images', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'id', i.id, 'languageCode', i.language_code, 'deviceType', i.device_type,
                'imagePosition', i.image_position, 'imageUrl', i.image_url,
                'imageUrl2x', i.image_url_2x, 'imageUrlWebp', i.image_url_webp,
                'width', i.width, 'height', i.height, 'objectFit', i.object_fit
            ) ORDER BY i.sort_order)
            FROM content.popup_images i WHERE i.popup_id = p.id AND i.is_active = TRUE
        ), '[]'::JSONB),
        'schedule', (
            SELECT jsonb_build_object(
                'daySunday', s.day_sunday, 'dayMonday', s.day_monday,
                'dayTuesday', s.day_tuesday, 'dayWednesday', s.day_wednesday,
                'dayThursday', s.day_thursday, 'dayFriday', s.day_friday,
                'daySaturday', s.day_saturday,
                'startTime', s.start_time, 'endTime', s.end_time,
                'timezone', s.timezone, 'priority', s.priority
            )
            FROM content.popup_schedules s WHERE s.popup_id = p.id AND s.is_active = TRUE
            LIMIT 1
        )
    ) INTO v_result
    FROM content.popups p
    WHERE p.id = p_id AND p.is_deleted = FALSE;

    IF v_result IS NULL THEN
        RAISE EXCEPTION 'error.popup.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION content.popup_get(INTEGER) IS 'Get popup detail with translations, images, and schedule.';
