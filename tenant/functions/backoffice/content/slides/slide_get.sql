-- ================================================================
-- SLIDE_GET: Slide detay (Backoffice)
-- ================================================================
-- NOT: Yetki kontrolü Core DB'de yapılır (user_assert_access_tenant)
-- ================================================================

DROP FUNCTION IF EXISTS content.slide_get(INTEGER, CHAR(2));

CREATE OR REPLACE FUNCTION content.slide_get(
    p_id INTEGER,
    p_lang CHAR(2) DEFAULT 'en'
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'id', s.id,
        'code', s.code,
        'placementId', s.placement_id,
        'placementCode', sp.code,
        'placementName', sp.name,
        'placementDescription', sp.description,
        'placementWidth', sp.width,
        'placementHeight', sp.height,
        'placementAspectRatio', sp.aspect_ratio,
        'categoryId', s.category_id,
        'sortOrder', s.sort_order,
        'priority', s.priority,
        -- Link
        'linkUrl', s.link_url,
        'linkTarget', s.link_target,
        'linkType', s.link_type,
        'linkReference', s.link_reference,
        -- Tarih
        'startDate', s.start_date,
        'endDate', s.end_date,
        -- Hedefleme
        'segmentIds', s.segment_ids,
        'countryCodes', s.country_codes,
        'excludedCountryCodes', s.excluded_country_codes,
        -- Görüntüleme
        'displayDuration', s.display_duration,
        'animationType', s.animation_type,
        -- Durum
        'isActive', s.is_active,
        -- Audit
        'createdAt', s.created_at,
        'createdBy', s.created_by,
        'updatedAt', s.updated_at,
        'updatedBy', s.updated_by,
        -- Çeviri (istenen dil)
        'title', COALESCE(st.title, st_en.title),
        'subtitle', COALESCE(st.subtitle, st_en.subtitle),
        'buttonText', COALESCE(st.button_text, st_en.button_text),
        -- Tüm çeviriler
        'translations', (
            SELECT COALESCE(jsonb_object_agg(t.language_code, jsonb_build_object(
                'title', t.title,
                'subtitle', t.subtitle,
                'buttonText', t.button_text
            )), '{}'::jsonb)
            FROM content.slide_translations t
            WHERE t.slide_id = s.id
        ),
        -- Resimler
        'images', (
            SELECT COALESCE(jsonb_agg(jsonb_build_object(
                'id', si.id,
                'imageUrl', si.image_url,
                'mobileImageUrl', si.mobile_image_url,
                'languageCode', si.language_code,
                'altText', si.alt_text,
                'isDefault', si.is_default
            ) ORDER BY si.is_default DESC, si.id), '[]'::jsonb)
            FROM content.slide_images si
            WHERE si.slide_id = s.id
        )
    )
    INTO v_result
    FROM content.slides s
    LEFT JOIN content.slide_placements sp ON sp.id = s.placement_id
    LEFT JOIN content.slide_translations st ON st.slide_id = s.id AND st.language_code = p_lang
    LEFT JOIN content.slide_translations st_en ON st_en.slide_id = s.id AND st_en.language_code = 'en'
    WHERE s.id = p_id AND s.is_deleted = FALSE;

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.slide.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION content.slide_get IS 'Gets slide detail with translations and images. Auth check done in Core DB.';
