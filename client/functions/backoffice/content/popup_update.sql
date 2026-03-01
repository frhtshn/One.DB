-- ================================================================
-- POPUP_UPDATE: Popup güncelle
-- Tüm alt kayıtlar dahil (DELETE + INSERT semantiği)
-- ================================================================

DROP FUNCTION IF EXISTS content.popup_update(INTEGER, JSONB, JSONB, JSONB, JSONB, JSONB, INTEGER);

CREATE OR REPLACE FUNCTION content.popup_update(
    p_id                INTEGER,            -- Popup ID
    p_config            JSONB       DEFAULT NULL,
    p_targeting         JSONB       DEFAULT NULL,
    p_translations      JSONB       DEFAULT NULL,
    p_images            JSONB       DEFAULT NULL,
    p_schedule          JSONB       DEFAULT NULL,
    p_user_id           INTEGER     DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_item JSONB;
BEGIN
    IF p_id IS NULL THEN
        RAISE EXCEPTION 'error.popup.id-required';
    END IF;

    IF p_user_id IS NULL THEN
        RAISE EXCEPTION 'error.popup.user-id-required';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM content.popups WHERE id = p_id AND is_deleted = FALSE) THEN
        RAISE EXCEPTION 'error.popup.not-found';
    END IF;

    -- Ana kayıt güncelle
    IF p_config IS NOT NULL THEN
        UPDATE content.popups
        SET display_duration        = COALESCE((p_config ->> 'displayDuration')::INTEGER, display_duration),
            auto_close              = COALESCE((p_config ->> 'autoClose')::BOOLEAN, auto_close),
            width                   = COALESCE((p_config ->> 'width')::INTEGER, width),
            height                  = COALESCE((p_config ->> 'height')::INTEGER, height),
            trigger_type            = COALESCE(p_config ->> 'triggerType', trigger_type),
            trigger_delay           = COALESCE((p_config ->> 'triggerDelay')::INTEGER, trigger_delay),
            trigger_scroll_percent  = COALESCE((p_config ->> 'triggerScrollPercent')::INTEGER, trigger_scroll_percent),
            trigger_exit_intent     = COALESCE((p_config ->> 'triggerExitIntent')::BOOLEAN, trigger_exit_intent),
            frequency_type          = COALESCE(p_config ->> 'frequencyType', frequency_type),
            frequency_cap           = COALESCE((p_config ->> 'frequencyCap')::INTEGER, frequency_cap),
            frequency_hours         = COALESCE((p_config ->> 'frequencyHours')::INTEGER, frequency_hours),
            link_url                = COALESCE(p_config ->> 'linkUrl', link_url),
            link_target             = COALESCE(p_config ->> 'linkTarget', link_target),
            start_date              = COALESCE((p_config ->> 'startDate')::TIMESTAMP, start_date),
            end_date                = COALESCE((p_config ->> 'endDate')::TIMESTAMP, end_date),
            priority                = COALESCE((p_config ->> 'priority')::INTEGER, priority),
            updated_by              = p_user_id,
            updated_at              = NOW()
        WHERE id = p_id;
    END IF;

    -- Hedefleme güncelle
    IF p_targeting IS NOT NULL THEN
        UPDATE content.popups
        SET segment_ids             = (SELECT array_agg(x::INTEGER) FROM jsonb_array_elements_text(p_targeting -> 'segmentIds') x),
            country_codes           = (SELECT array_agg(x::TEXT) FROM jsonb_array_elements_text(p_targeting -> 'countryCodes') x),
            excluded_country_codes  = (SELECT array_agg(x::TEXT) FROM jsonb_array_elements_text(p_targeting -> 'excludedCountryCodes') x),
            page_urls               = (SELECT array_agg(x::TEXT) FROM jsonb_array_elements_text(p_targeting -> 'pageUrls') x),
            excluded_page_urls      = (SELECT array_agg(x::TEXT) FROM jsonb_array_elements_text(p_targeting -> 'excludedPageUrls') x),
            updated_by              = p_user_id,
            updated_at              = NOW()
        WHERE id = p_id;
    END IF;

    -- Çeviriler (DELETE + INSERT)
    IF p_translations IS NOT NULL THEN
        DELETE FROM content.popup_translations WHERE popup_id = p_id;
        IF jsonb_array_length(p_translations) > 0 THEN
            FOR v_item IN SELECT * FROM jsonb_array_elements(p_translations)
            LOOP
                INSERT INTO content.popup_translations (
                    popup_id, language_code, title, subtitle, body_text,
                    cta_text, cta_secondary_text, close_button_text, created_by, updated_by
                )
                VALUES (
                    p_id, v_item ->> 'languageCode',
                    v_item ->> 'title', v_item ->> 'subtitle', v_item ->> 'bodyText',
                    v_item ->> 'ctaText', v_item ->> 'ctaSecondaryText',
                    v_item ->> 'closeButtonText', p_user_id, p_user_id
                );
            END LOOP;
        END IF;
    END IF;

    -- Görseller (DELETE + INSERT)
    IF p_images IS NOT NULL THEN
        DELETE FROM content.popup_images WHERE popup_id = p_id;
        IF jsonb_array_length(p_images) > 0 THEN
            FOR v_item IN SELECT * FROM jsonb_array_elements(p_images)
            LOOP
                INSERT INTO content.popup_images (
                    popup_id, language_code, device_type, image_position,
                    image_url, image_url_2x, image_url_webp,
                    width, height, file_size, object_fit, border_radius,
                    created_by, updated_by
                )
                VALUES (
                    p_id, v_item ->> 'languageCode',
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
    END IF;

    -- Zamanlama (DELETE + INSERT)
    IF p_schedule IS NOT NULL THEN
        DELETE FROM content.popup_schedules WHERE popup_id = p_id;
        INSERT INTO content.popup_schedules (
            popup_id,
            day_sunday, day_monday, day_tuesday, day_wednesday,
            day_thursday, day_friday, day_saturday,
            start_time, end_time, timezone, priority, created_by, updated_by
        )
        VALUES (
            p_id,
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
END;
$$;

COMMENT ON FUNCTION content.popup_update(INTEGER, JSONB, JSONB, JSONB, JSONB, JSONB, INTEGER) IS 'Update popup with config, targeting, translations, images, and schedule. Sub-records use delete+insert semantics.';
