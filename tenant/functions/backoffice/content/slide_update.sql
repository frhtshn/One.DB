-- ================================================================
-- SLIDE_UPDATE: Slide güncelle
-- Tüm alt kayıtlar dahil (DELETE + INSERT semantiği)
-- ================================================================

DROP FUNCTION IF EXISTS content.slide_update(INTEGER, JSONB, JSONB, JSONB, JSONB, JSONB, INTEGER);

CREATE OR REPLACE FUNCTION content.slide_update(
    p_id                INTEGER,
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
    IF p_id IS NULL THEN RAISE EXCEPTION 'error.slide.id-required'; END IF;
    IF p_user_id IS NULL THEN RAISE EXCEPTION 'error.slide.user-id-required'; END IF;

    IF NOT EXISTS (SELECT 1 FROM content.slides WHERE id = p_id AND is_deleted = FALSE) THEN
        RAISE EXCEPTION 'error.slide.not-found';
    END IF;

    IF p_config IS NOT NULL THEN
        UPDATE content.slides
        SET sort_order       = COALESCE((p_config ->> 'sortOrder')::INTEGER, sort_order),
            priority         = COALESCE((p_config ->> 'priority')::INTEGER, priority),
            link_url         = COALESCE(p_config ->> 'linkUrl', link_url),
            link_target      = COALESCE(p_config ->> 'linkTarget', link_target),
            link_type        = COALESCE(p_config ->> 'linkType', link_type),
            link_reference   = COALESCE(p_config ->> 'linkReference', link_reference),
            start_date       = COALESCE((p_config ->> 'startDate')::TIMESTAMP, start_date),
            end_date         = COALESCE((p_config ->> 'endDate')::TIMESTAMP, end_date),
            display_duration = COALESCE((p_config ->> 'displayDuration')::INTEGER, display_duration),
            animation_type   = COALESCE(p_config ->> 'animationType', animation_type),
            updated_by = p_user_id, updated_at = NOW()
        WHERE id = p_id;
    END IF;

    IF p_targeting IS NOT NULL THEN
        UPDATE content.slides
        SET segment_ids            = (SELECT array_agg(x::INTEGER) FROM jsonb_array_elements_text(p_targeting -> 'segmentIds') x),
            country_codes          = (SELECT array_agg(x::CHAR(2)) FROM jsonb_array_elements_text(p_targeting -> 'countryCodes') x),
            excluded_country_codes = (SELECT array_agg(x::CHAR(2)) FROM jsonb_array_elements_text(p_targeting -> 'excludedCountryCodes') x),
            updated_by = p_user_id, updated_at = NOW()
        WHERE id = p_id;
    END IF;

    IF p_translations IS NOT NULL THEN
        DELETE FROM content.slide_translations WHERE slide_id = p_id;
        IF jsonb_array_length(p_translations) > 0 THEN
            FOR v_item IN SELECT * FROM jsonb_array_elements(p_translations) LOOP
                INSERT INTO content.slide_translations (slide_id, language_code, title, subtitle, description, cta_text, cta_secondary_text, alt_text, created_by, updated_by)
                VALUES (p_id, v_item ->> 'languageCode', v_item ->> 'title', v_item ->> 'subtitle', v_item ->> 'description', v_item ->> 'ctaText', v_item ->> 'ctaSecondaryText', v_item ->> 'altText', p_user_id, p_user_id);
            END LOOP;
        END IF;
    END IF;

    IF p_images IS NOT NULL THEN
        DELETE FROM content.slide_images WHERE slide_id = p_id;
        IF jsonb_array_length(p_images) > 0 THEN
            FOR v_item IN SELECT * FROM jsonb_array_elements(p_images) LOOP
                INSERT INTO content.slide_images (slide_id, language_code, device_type, image_url, image_url_2x, image_url_webp, width, height, file_size, fallback_color, created_by, updated_by)
                VALUES (p_id, v_item ->> 'languageCode', COALESCE(v_item ->> 'deviceType', 'desktop'), v_item ->> 'imageUrl', v_item ->> 'imageUrl2x', v_item ->> 'imageUrlWebp', (v_item ->> 'width')::INTEGER, (v_item ->> 'height')::INTEGER, (v_item ->> 'fileSize')::INTEGER, v_item ->> 'fallbackColor', p_user_id, p_user_id);
            END LOOP;
        END IF;
    END IF;

    IF p_schedule IS NOT NULL THEN
        DELETE FROM content.slide_schedules WHERE slide_id = p_id;
        INSERT INTO content.slide_schedules (slide_id, day_sunday, day_monday, day_tuesday, day_wednesday, day_thursday, day_friday, day_saturday, start_time, end_time, timezone, priority, created_by, updated_by)
        VALUES (p_id, COALESCE((p_schedule ->> 'daySunday')::BOOLEAN, TRUE), COALESCE((p_schedule ->> 'dayMonday')::BOOLEAN, TRUE), COALESCE((p_schedule ->> 'dayTuesday')::BOOLEAN, TRUE), COALESCE((p_schedule ->> 'dayWednesday')::BOOLEAN, TRUE), COALESCE((p_schedule ->> 'dayThursday')::BOOLEAN, TRUE), COALESCE((p_schedule ->> 'dayFriday')::BOOLEAN, TRUE), COALESCE((p_schedule ->> 'daySaturday')::BOOLEAN, TRUE), (p_schedule ->> 'startTime')::TIME, (p_schedule ->> 'endTime')::TIME, COALESCE(p_schedule ->> 'timezone', 'UTC'), COALESCE((p_schedule ->> 'priority')::INTEGER, 0), p_user_id, p_user_id);
    END IF;
END;
$$;

COMMENT ON FUNCTION content.slide_update(INTEGER, JSONB, JSONB, JSONB, JSONB, JSONB, INTEGER) IS 'Update slide with all sub-records using delete+insert semantics.';
