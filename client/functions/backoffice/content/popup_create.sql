-- ================================================================
-- POPUP_CREATE: Popup oluştur
-- Config + hedefleme + çeviriler + görseller + zamanlama
-- ================================================================

DROP FUNCTION IF EXISTS content.popup_create(INTEGER, VARCHAR, JSONB, JSONB, JSONB, JSONB, JSONB, INTEGER);

CREATE OR REPLACE FUNCTION content.popup_create(
    p_popup_type_id     INTEGER,            -- Popup tipi
    p_code              VARCHAR(50) DEFAULT NULL, -- Benzersiz kod
    p_config            JSONB       DEFAULT NULL, -- {displayDuration, autoClose, width, height, triggerType, ...}
    p_targeting         JSONB       DEFAULT NULL, -- {segmentIds[], countryCodes[], pageUrls[], ...}
    p_translations      JSONB       DEFAULT NULL, -- [{languageCode, title, subtitle, bodyText, ctaText, ...}]
    p_images            JSONB       DEFAULT NULL, -- [{languageCode, deviceType, imagePosition, imageUrl, ...}]
    p_schedule          JSONB       DEFAULT NULL, -- {daySunday..daySaturday, startTime, endTime, timezone}
    p_user_id           INTEGER     DEFAULT NULL  -- İşlemi yapan kullanıcı
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_id INTEGER;
    v_item JSONB;
BEGIN
    IF p_popup_type_id IS NULL THEN
        RAISE EXCEPTION 'error.popup.type-id-required';
    END IF;

    IF p_user_id IS NULL THEN
        RAISE EXCEPTION 'error.popup.user-id-required';
    END IF;

    -- Ana kayıt
    INSERT INTO content.popups (
        popup_type_id, code,
        display_duration, auto_close, width, height,
        trigger_type, trigger_delay, trigger_scroll_percent, trigger_exit_intent,
        frequency_type, frequency_cap, frequency_hours,
        link_url, link_target, start_date, end_date, priority,
        segment_ids, country_codes, excluded_country_codes,
        page_urls, excluded_page_urls,
        created_by, updated_by
    )
    VALUES (
        p_popup_type_id, p_code,
        (p_config ->> 'displayDuration')::INTEGER,
        (p_config ->> 'autoClose')::BOOLEAN,
        (p_config ->> 'width')::INTEGER,
        (p_config ->> 'height')::INTEGER,
        COALESCE(p_config ->> 'triggerType', 'immediate'),
        (p_config ->> 'triggerDelay')::INTEGER,
        (p_config ->> 'triggerScrollPercent')::INTEGER,
        (p_config ->> 'triggerExitIntent')::BOOLEAN,
        COALESCE(p_config ->> 'frequencyType', 'always'),
        (p_config ->> 'frequencyCap')::INTEGER,
        (p_config ->> 'frequencyHours')::INTEGER,
        p_config ->> 'linkUrl',
        p_config ->> 'linkTarget',
        (p_config ->> 'startDate')::TIMESTAMP,
        (p_config ->> 'endDate')::TIMESTAMP,
        COALESCE((p_config ->> 'priority')::INTEGER, 0),
        -- Hedefleme
        CASE WHEN p_targeting IS NOT NULL THEN
            (SELECT array_agg(x::INTEGER) FROM jsonb_array_elements_text(p_targeting -> 'segmentIds') x)
        END,
        CASE WHEN p_targeting IS NOT NULL THEN
            (SELECT array_agg(x::TEXT) FROM jsonb_array_elements_text(p_targeting -> 'countryCodes') x)
        END,
        CASE WHEN p_targeting IS NOT NULL THEN
            (SELECT array_agg(x::TEXT) FROM jsonb_array_elements_text(p_targeting -> 'excludedCountryCodes') x)
        END,
        CASE WHEN p_targeting IS NOT NULL THEN
            (SELECT array_agg(x::TEXT) FROM jsonb_array_elements_text(p_targeting -> 'pageUrls') x)
        END,
        CASE WHEN p_targeting IS NOT NULL THEN
            (SELECT array_agg(x::TEXT) FROM jsonb_array_elements_text(p_targeting -> 'excludedPageUrls') x)
        END,
        p_user_id, p_user_id
    )
    RETURNING id INTO v_id;

    -- Çeviriler
    IF p_translations IS NOT NULL AND jsonb_array_length(p_translations) > 0 THEN
        FOR v_item IN SELECT * FROM jsonb_array_elements(p_translations)
        LOOP
            INSERT INTO content.popup_translations (
                popup_id, language_code, title, subtitle, body_text,
                cta_text, cta_secondary_text, close_button_text, created_by, updated_by
            )
            VALUES (
                v_id, v_item ->> 'languageCode',
                v_item ->> 'title', v_item ->> 'subtitle', v_item ->> 'bodyText',
                v_item ->> 'ctaText', v_item ->> 'ctaSecondaryText',
                v_item ->> 'closeButtonText', p_user_id, p_user_id
            );
        END LOOP;
    END IF;

    -- Görseller
    IF p_images IS NOT NULL AND jsonb_array_length(p_images) > 0 THEN
        FOR v_item IN SELECT * FROM jsonb_array_elements(p_images)
        LOOP
            INSERT INTO content.popup_images (
                popup_id, language_code, device_type, image_position,
                image_url, image_url_2x, image_url_webp,
                width, height, file_size, object_fit, border_radius,
                created_by, updated_by
            )
            VALUES (
                v_id, v_item ->> 'languageCode',
                COALESCE(v_item ->> 'deviceType', 'desktop'),
                COALESCE(v_item ->> 'imagePosition', 'top'),
                v_item ->> 'imageUrl', v_item ->> 'imageUrl2x', v_item ->> 'imageUrlWebp',
                (v_item ->> 'width')::INTEGER, (v_item ->> 'height')::INTEGER,
                (v_item ->> 'fileSize')::INTEGER,
                COALESCE(v_item ->> 'objectFit', 'cover'),
                COALESCE((v_item ->> 'borderRadius')::INTEGER, 0),
                p_user_id, p_user_id
            );
        END LOOP;
    END IF;

    -- Zamanlama
    IF p_schedule IS NOT NULL THEN
        INSERT INTO content.popup_schedules (
            popup_id,
            day_sunday, day_monday, day_tuesday, day_wednesday,
            day_thursday, day_friday, day_saturday,
            start_time, end_time, timezone, priority,
            created_by, updated_by
        )
        VALUES (
            v_id,
            COALESCE((p_schedule ->> 'daySunday')::BOOLEAN, TRUE),
            COALESCE((p_schedule ->> 'dayMonday')::BOOLEAN, TRUE),
            COALESCE((p_schedule ->> 'dayTuesday')::BOOLEAN, TRUE),
            COALESCE((p_schedule ->> 'dayWednesday')::BOOLEAN, TRUE),
            COALESCE((p_schedule ->> 'dayThursday')::BOOLEAN, TRUE),
            COALESCE((p_schedule ->> 'dayFriday')::BOOLEAN, TRUE),
            COALESCE((p_schedule ->> 'daySaturday')::BOOLEAN, TRUE),
            (p_schedule ->> 'startTime')::TIME,
            (p_schedule ->> 'endTime')::TIME,
            COALESCE(p_schedule ->> 'timezone', 'UTC'),
            COALESCE((p_schedule ->> 'priority')::INTEGER, 0),
            p_user_id, p_user_id
        );
    END IF;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION content.popup_create(INTEGER, VARCHAR, JSONB, JSONB, JSONB, JSONB, JSONB, INTEGER) IS 'Create popup with config, targeting, translations, images, and schedule in a single call.';
