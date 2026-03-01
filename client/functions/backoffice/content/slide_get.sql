-- ================================================================
-- SLIDE_GET: Slide detay getir
-- Tüm ilişkili veriler dahil
-- ================================================================

DROP FUNCTION IF EXISTS content.slide_get(INTEGER);

CREATE OR REPLACE FUNCTION content.slide_get(
    p_id                INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    IF p_id IS NULL THEN RAISE EXCEPTION 'error.slide.id-required'; END IF;

    SELECT jsonb_build_object(
        'id', s.id, 'placementId', s.placement_id, 'categoryId', s.category_id,
        'code', s.code, 'sortOrder', s.sort_order, 'priority', s.priority,
        'linkUrl', s.link_url, 'linkTarget', s.link_target,
        'linkType', s.link_type, 'linkReference', s.link_reference,
        'startDate', s.start_date, 'endDate', s.end_date,
        'displayDuration', s.display_duration, 'animationType', s.animation_type,
        'segmentIds', s.segment_ids, 'countryCodes', s.country_codes,
        'excludedCountryCodes', s.excluded_country_codes,
        'isActive', s.is_active, 'createdAt', s.created_at, 'updatedAt', s.updated_at,
        'translations', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'id', t.id, 'languageCode', t.language_code,
                'title', t.title, 'subtitle', t.subtitle, 'description', t.description,
                'ctaText', t.cta_text, 'ctaSecondaryText', t.cta_secondary_text, 'altText', t.alt_text
            ) ORDER BY t.language_code)
            FROM content.slide_translations t WHERE t.slide_id = s.id
        ), '[]'::JSONB),
        'images', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'id', i.id, 'languageCode', i.language_code, 'deviceType', i.device_type,
                'imageUrl', i.image_url, 'imageUrl2x', i.image_url_2x, 'imageUrlWebp', i.image_url_webp,
                'width', i.width, 'height', i.height, 'fallbackColor', i.fallback_color
            ) ORDER BY i.sort_order)
            FROM content.slide_images i WHERE i.slide_id = s.id AND i.is_active = TRUE
        ), '[]'::JSONB),
        'schedule', (
            SELECT jsonb_build_object(
                'daySunday', sc.day_sunday, 'dayMonday', sc.day_monday,
                'dayTuesday', sc.day_tuesday, 'dayWednesday', sc.day_wednesday,
                'dayThursday', sc.day_thursday, 'dayFriday', sc.day_friday,
                'daySaturday', sc.day_saturday,
                'startTime', sc.start_time, 'endTime', sc.end_time,
                'timezone', sc.timezone, 'priority', sc.priority
            )
            FROM content.slide_schedules sc WHERE sc.slide_id = s.id AND sc.is_active = TRUE LIMIT 1
        )
    ) INTO v_result
    FROM content.slides s
    WHERE s.id = p_id AND s.is_deleted = FALSE;

    IF v_result IS NULL THEN RAISE EXCEPTION 'error.slide.not-found'; END IF;
    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION content.slide_get(INTEGER) IS 'Get slide detail with translations, images, and schedule.';
