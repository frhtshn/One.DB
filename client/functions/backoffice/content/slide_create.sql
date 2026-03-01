-- ================================================================
-- SLIDE_CREATE: Slide oluştur
-- Config + hedefleme + çeviriler + görseller + zamanlama
-- ================================================================

DROP FUNCTION IF EXISTS content.slide_create(INTEGER, INTEGER, VARCHAR, JSONB, JSONB, JSONB, JSONB, JSONB, INTEGER);

CREATE OR REPLACE FUNCTION content.slide_create(
    p_placement_id      INTEGER,
    p_category_id       INTEGER         DEFAULT NULL,
    p_code              VARCHAR(50)     DEFAULT NULL,
    p_config            JSONB           DEFAULT NULL,   -- {sortOrder, priority, linkUrl, linkTarget, linkType, linkReference, startDate, endDate, displayDuration, animationType}
    p_targeting         JSONB           DEFAULT NULL,   -- {segmentIds[], countryCodes[], excludedCountryCodes[]}
    p_translations      JSONB           DEFAULT NULL,   -- [{languageCode, title, subtitle, description, ctaText, ctaSecondaryText, altText}]
    p_images            JSONB           DEFAULT NULL,   -- [{languageCode, deviceType, imageUrl, imageUrl2x, imageUrlWebp, width, height, fileSize, fallbackColor}]
    p_schedule          JSONB           DEFAULT NULL,   -- {daySunday..daySaturday, startTime, endTime, timezone, priority}
    p_user_id           INTEGER         DEFAULT NULL
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_id INTEGER;
    v_item JSONB;
BEGIN
    IF p_placement_id IS NULL THEN RAISE EXCEPTION 'error.slide.placement-id-required'; END IF;
    IF p_user_id IS NULL THEN RAISE EXCEPTION 'error.slide.user-id-required'; END IF;

    -- Ana kayıt
    INSERT INTO content.slides (
        placement_id, category_id, code,
        sort_order, priority, link_url, link_target, link_type, link_reference,
        start_date, end_date, display_duration, animation_type,
        segment_ids, country_codes, excluded_country_codes,
        created_by, updated_by
    )
    VALUES (
        p_placement_id, p_category_id, p_code,
        COALESCE((p_config ->> 'sortOrder')::INTEGER, 0),
        COALESCE((p_config ->> 'priority')::INTEGER, 0),
        p_config ->> 'linkUrl',
        COALESCE(p_config ->> 'linkTarget', '_self'),
        COALESCE(p_config ->> 'linkType', 'url'),
        p_config ->> 'linkReference',
        (p_config ->> 'startDate')::TIMESTAMP,
        (p_config ->> 'endDate')::TIMESTAMP,
        (p_config ->> 'displayDuration')::INTEGER,
        COALESCE(p_config ->> 'animationType', 'fade'),
        CASE WHEN p_targeting IS NOT NULL THEN
            (SELECT array_agg(x::INTEGER) FROM jsonb_array_elements_text(p_targeting -> 'segmentIds') x)
        END,
        CASE WHEN p_targeting IS NOT NULL THEN
            (SELECT array_agg(x::CHAR(2)) FROM jsonb_array_elements_text(p_targeting -> 'countryCodes') x)
        END,
        CASE WHEN p_targeting IS NOT NULL THEN
            (SELECT array_agg(x::CHAR(2)) FROM jsonb_array_elements_text(p_targeting -> 'excludedCountryCodes') x)
        END,
        p_user_id, p_user_id
    )
    RETURNING id INTO v_id;

    -- Çeviriler
    IF p_translations IS NOT NULL AND jsonb_array_length(p_translations) > 0 THEN
        FOR v_item IN SELECT * FROM jsonb_array_elements(p_translations) LOOP
            INSERT INTO content.slide_translations (
                slide_id, language_code, title, subtitle, description,
                cta_text, cta_secondary_text, alt_text, created_by, updated_by
            ) VALUES (
                v_id, v_item ->> 'languageCode',
                v_item ->> 'title', v_item ->> 'subtitle', v_item ->> 'description',
                v_item ->> 'ctaText', v_item ->> 'ctaSecondaryText', v_item ->> 'altText',
                p_user_id, p_user_id
            );
        END LOOP;
    END IF;

    -- Görseller
    IF p_images IS NOT NULL AND jsonb_array_length(p_images) > 0 THEN
        FOR v_item IN SELECT * FROM jsonb_array_elements(p_images) LOOP
            INSERT INTO content.slide_images (
                slide_id, language_code, device_type, image_url, image_url_2x, image_url_webp,
                width, height, file_size, fallback_color, created_by, updated_by
            ) VALUES (
                v_id, v_item ->> 'languageCode',
                COALESCE(v_item ->> 'deviceType', 'desktop'),
                v_item ->> 'imageUrl', v_item ->> 'imageUrl2x', v_item ->> 'imageUrlWebp',
                (v_item ->> 'width')::INTEGER, (v_item ->> 'height')::INTEGER,
                (v_item ->> 'fileSize')::INTEGER, v_item ->> 'fallbackColor',
                p_user_id, p_user_id
            );
        END LOOP;
    END IF;

    -- Zamanlama
    IF p_schedule IS NOT NULL THEN
        INSERT INTO content.slide_schedules (
            slide_id, day_sunday, day_monday, day_tuesday, day_wednesday,
            day_thursday, day_friday, day_saturday,
            start_time, end_time, timezone, priority, created_by, updated_by
        ) VALUES (
            v_id,
            COALESCE((p_schedule ->> 'daySunday')::BOOLEAN, TRUE),
            COALESCE((p_schedule ->> 'dayMonday')::BOOLEAN, TRUE),
            COALESCE((p_schedule ->> 'dayTuesday')::BOOLEAN, TRUE),
            COALESCE((p_schedule ->> 'dayWednesday')::BOOLEAN, TRUE),
            COALESCE((p_schedule ->> 'dayThursday')::BOOLEAN, TRUE),
            COALESCE((p_schedule ->> 'dayFriday')::BOOLEAN, TRUE),
            COALESCE((p_schedule ->> 'daySaturday')::BOOLEAN, TRUE),
            (p_schedule ->> 'startTime')::TIME, (p_schedule ->> 'endTime')::TIME,
            COALESCE(p_schedule ->> 'timezone', 'UTC'),
            COALESCE((p_schedule ->> 'priority')::INTEGER, 0),
            p_user_id, p_user_id
        );
    END IF;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION content.slide_create(INTEGER, INTEGER, VARCHAR, JSONB, JSONB, JSONB, JSONB, JSONB, INTEGER) IS 'Create slide with config, targeting, translations, images, and schedule.';
