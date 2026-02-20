-- ================================================================
-- PROMOTION_CREATE: Promosyon oluştur
-- Çeviriler + bannerlar + segmentler + oyunlar + lokasyonlar
-- ================================================================

DROP FUNCTION IF EXISTS content.promotion_create(VARCHAR, INTEGER, INTEGER, NUMERIC, NUMERIC, TIMESTAMP, TIMESTAMP, INTEGER, BOOLEAN, BOOLEAN, JSONB, JSONB, JSONB, JSONB, JSONB, INTEGER);

CREATE OR REPLACE FUNCTION content.promotion_create(
    p_code                  VARCHAR(50),
    p_promotion_type_id     INTEGER,
    p_bonus_id              INTEGER         DEFAULT NULL,
    p_min_deposit           NUMERIC(18,2)   DEFAULT NULL,
    p_max_deposit           NUMERIC(18,2)   DEFAULT NULL,
    p_start_date            TIMESTAMP       DEFAULT NULL,
    p_end_date              TIMESTAMP       DEFAULT NULL,
    p_sort_order            INTEGER         DEFAULT 0,
    p_is_featured           BOOLEAN         DEFAULT FALSE,
    p_is_new_members_only   BOOLEAN         DEFAULT FALSE,
    p_translations          JSONB           DEFAULT NULL,   -- [{languageCode, title, subtitle, summary, description, termsConditions, ctaText, ctaUrl, metaTitle, metaDescription}]
    p_banners               JSONB           DEFAULT NULL,   -- [{languageCode, deviceType, imageUrl, altText, width, height}]
    p_segments              JSONB           DEFAULT NULL,   -- [{segmentType, segmentValue, isInclude}]
    p_games                 JSONB           DEFAULT NULL,   -- [{filterType, filterValue, isInclude}]
    p_display_locations     JSONB           DEFAULT NULL,   -- [{locationCode, sortOrder}]
    p_user_id               INTEGER         DEFAULT NULL
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_id INTEGER;
    v_item JSONB;
BEGIN
    IF p_code IS NULL OR p_code = '' THEN
        RAISE EXCEPTION 'error.promotion.code-required';
    END IF;
    IF p_promotion_type_id IS NULL THEN
        RAISE EXCEPTION 'error.promotion.type-id-required';
    END IF;
    IF p_user_id IS NULL THEN
        RAISE EXCEPTION 'error.promotion.user-id-required';
    END IF;

    -- Ana kayıt
    INSERT INTO content.promotions (
        code, promotion_type_id, bonus_id, min_deposit, max_deposit,
        start_date, end_date, sort_order, is_featured, is_new_members_only,
        created_by, updated_by
    )
    VALUES (
        p_code, p_promotion_type_id, p_bonus_id, p_min_deposit, p_max_deposit,
        p_start_date, p_end_date, COALESCE(p_sort_order, 0),
        COALESCE(p_is_featured, FALSE), COALESCE(p_is_new_members_only, FALSE),
        p_user_id, p_user_id
    )
    RETURNING id INTO v_id;

    -- Çeviriler
    IF p_translations IS NOT NULL AND jsonb_array_length(p_translations) > 0 THEN
        FOR v_item IN SELECT * FROM jsonb_array_elements(p_translations)
        LOOP
            INSERT INTO content.promotion_translations (
                promotion_id, language_code, title, subtitle, summary, description,
                terms_conditions, cta_text, cta_url, meta_title, meta_description,
                created_by, updated_by
            )
            VALUES (
                v_id, v_item ->> 'languageCode',
                v_item ->> 'title', v_item ->> 'subtitle', v_item ->> 'summary',
                v_item ->> 'description', v_item ->> 'termsConditions',
                v_item ->> 'ctaText', v_item ->> 'ctaUrl',
                v_item ->> 'metaTitle', v_item ->> 'metaDescription',
                p_user_id, p_user_id
            );
        END LOOP;
    END IF;

    -- Bannerlar
    IF p_banners IS NOT NULL AND jsonb_array_length(p_banners) > 0 THEN
        FOR v_item IN SELECT * FROM jsonb_array_elements(p_banners)
        LOOP
            INSERT INTO content.promotion_banners (
                promotion_id, language_code, device_type, image_url, alt_text,
                width, height, created_by
            )
            VALUES (
                v_id, v_item ->> 'languageCode',
                COALESCE(v_item ->> 'deviceType', 'desktop'),
                v_item ->> 'imageUrl', v_item ->> 'altText',
                (v_item ->> 'width')::INTEGER, (v_item ->> 'height')::INTEGER,
                p_user_id
            );
        END LOOP;
    END IF;

    -- Segmentler
    IF p_segments IS NOT NULL AND jsonb_array_length(p_segments) > 0 THEN
        FOR v_item IN SELECT * FROM jsonb_array_elements(p_segments)
        LOOP
            INSERT INTO content.promotion_segments (
                promotion_id, segment_type, segment_value, is_include, created_by
            )
            VALUES (
                v_id, v_item ->> 'segmentType', v_item ->> 'segmentValue',
                COALESCE((v_item ->> 'isInclude')::BOOLEAN, TRUE), p_user_id
            );
        END LOOP;
    END IF;

    -- Oyunlar
    IF p_games IS NOT NULL AND jsonb_array_length(p_games) > 0 THEN
        FOR v_item IN SELECT * FROM jsonb_array_elements(p_games)
        LOOP
            INSERT INTO content.promotion_games (
                promotion_id, filter_type, filter_value, is_include, created_by
            )
            VALUES (
                v_id, v_item ->> 'filterType', v_item ->> 'filterValue',
                COALESCE((v_item ->> 'isInclude')::BOOLEAN, TRUE), p_user_id
            );
        END LOOP;
    END IF;

    -- Görüntüleme lokasyonları
    IF p_display_locations IS NOT NULL AND jsonb_array_length(p_display_locations) > 0 THEN
        FOR v_item IN SELECT * FROM jsonb_array_elements(p_display_locations)
        LOOP
            INSERT INTO content.promotion_display_locations (
                promotion_id, location_code, sort_order, created_by
            )
            VALUES (
                v_id, v_item ->> 'locationCode',
                COALESCE((v_item ->> 'sortOrder')::INTEGER, 0), p_user_id
            );
        END LOOP;
    END IF;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION content.promotion_create(VARCHAR, INTEGER, INTEGER, NUMERIC, NUMERIC, TIMESTAMP, TIMESTAMP, INTEGER, BOOLEAN, BOOLEAN, JSONB, JSONB, JSONB, JSONB, JSONB, INTEGER) IS 'Create promotion with translations, banners, segments, game filters, and display locations.';
