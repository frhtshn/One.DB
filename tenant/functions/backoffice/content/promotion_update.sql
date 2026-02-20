-- ================================================================
-- PROMOTION_UPDATE: Promosyon güncelle
-- Tüm alt kayıtlar dahil (DELETE + INSERT semantiği)
-- ================================================================

DROP FUNCTION IF EXISTS content.promotion_update(INTEGER, INTEGER, NUMERIC, NUMERIC, TIMESTAMP, TIMESTAMP, INTEGER, BOOLEAN, BOOLEAN, JSONB, JSONB, JSONB, JSONB, JSONB, INTEGER);

CREATE OR REPLACE FUNCTION content.promotion_update(
    p_id                    INTEGER,
    p_bonus_id              INTEGER         DEFAULT NULL,
    p_min_deposit           NUMERIC(18,2)   DEFAULT NULL,
    p_max_deposit           NUMERIC(18,2)   DEFAULT NULL,
    p_start_date            TIMESTAMP       DEFAULT NULL,
    p_end_date              TIMESTAMP       DEFAULT NULL,
    p_sort_order            INTEGER         DEFAULT NULL,
    p_is_featured           BOOLEAN         DEFAULT NULL,
    p_is_new_members_only   BOOLEAN         DEFAULT NULL,
    p_translations          JSONB           DEFAULT NULL,
    p_banners               JSONB           DEFAULT NULL,
    p_segments              JSONB           DEFAULT NULL,
    p_games                 JSONB           DEFAULT NULL,
    p_display_locations     JSONB           DEFAULT NULL,
    p_user_id               INTEGER         DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_item JSONB;
BEGIN
    IF p_id IS NULL THEN RAISE EXCEPTION 'error.promotion.id-required'; END IF;
    IF p_user_id IS NULL THEN RAISE EXCEPTION 'error.promotion.user-id-required'; END IF;

    IF NOT EXISTS (SELECT 1 FROM content.promotions WHERE id = p_id AND is_active = TRUE) THEN
        RAISE EXCEPTION 'error.promotion.not-found';
    END IF;

    -- Ana kayıt
    UPDATE content.promotions
    SET bonus_id            = COALESCE(p_bonus_id, bonus_id),
        min_deposit         = COALESCE(p_min_deposit, min_deposit),
        max_deposit         = COALESCE(p_max_deposit, max_deposit),
        start_date          = COALESCE(p_start_date, start_date),
        end_date            = COALESCE(p_end_date, end_date),
        sort_order          = COALESCE(p_sort_order, sort_order),
        is_featured         = COALESCE(p_is_featured, is_featured),
        is_new_members_only = COALESCE(p_is_new_members_only, is_new_members_only),
        updated_by = p_user_id, updated_at = NOW()
    WHERE id = p_id;

    -- Alt kayıtlar: DELETE + INSERT
    IF p_translations IS NOT NULL THEN
        DELETE FROM content.promotion_translations WHERE promotion_id = p_id;
        IF jsonb_array_length(p_translations) > 0 THEN
            FOR v_item IN SELECT * FROM jsonb_array_elements(p_translations) LOOP
                INSERT INTO content.promotion_translations (
                    promotion_id, language_code, title, subtitle, summary, description,
                    terms_conditions, cta_text, cta_url, meta_title, meta_description,
                    created_by, updated_by
                ) VALUES (
                    p_id, v_item ->> 'languageCode',
                    v_item ->> 'title', v_item ->> 'subtitle', v_item ->> 'summary',
                    v_item ->> 'description', v_item ->> 'termsConditions',
                    v_item ->> 'ctaText', v_item ->> 'ctaUrl',
                    v_item ->> 'metaTitle', v_item ->> 'metaDescription',
                    p_user_id, p_user_id
                );
            END LOOP;
        END IF;
    END IF;

    IF p_banners IS NOT NULL THEN
        DELETE FROM content.promotion_banners WHERE promotion_id = p_id;
        IF jsonb_array_length(p_banners) > 0 THEN
            FOR v_item IN SELECT * FROM jsonb_array_elements(p_banners) LOOP
                INSERT INTO content.promotion_banners (promotion_id, language_code, device_type, image_url, alt_text, width, height, created_by)
                VALUES (p_id, v_item ->> 'languageCode', COALESCE(v_item ->> 'deviceType', 'desktop'), v_item ->> 'imageUrl', v_item ->> 'altText', (v_item ->> 'width')::INTEGER, (v_item ->> 'height')::INTEGER, p_user_id);
            END LOOP;
        END IF;
    END IF;

    IF p_segments IS NOT NULL THEN
        DELETE FROM content.promotion_segments WHERE promotion_id = p_id;
        IF jsonb_array_length(p_segments) > 0 THEN
            FOR v_item IN SELECT * FROM jsonb_array_elements(p_segments) LOOP
                INSERT INTO content.promotion_segments (promotion_id, segment_type, segment_value, is_include, created_by)
                VALUES (p_id, v_item ->> 'segmentType', v_item ->> 'segmentValue', COALESCE((v_item ->> 'isInclude')::BOOLEAN, TRUE), p_user_id);
            END LOOP;
        END IF;
    END IF;

    IF p_games IS NOT NULL THEN
        DELETE FROM content.promotion_games WHERE promotion_id = p_id;
        IF jsonb_array_length(p_games) > 0 THEN
            FOR v_item IN SELECT * FROM jsonb_array_elements(p_games) LOOP
                INSERT INTO content.promotion_games (promotion_id, filter_type, filter_value, is_include, created_by)
                VALUES (p_id, v_item ->> 'filterType', v_item ->> 'filterValue', COALESCE((v_item ->> 'isInclude')::BOOLEAN, TRUE), p_user_id);
            END LOOP;
        END IF;
    END IF;

    IF p_display_locations IS NOT NULL THEN
        DELETE FROM content.promotion_display_locations WHERE promotion_id = p_id;
        IF jsonb_array_length(p_display_locations) > 0 THEN
            FOR v_item IN SELECT * FROM jsonb_array_elements(p_display_locations) LOOP
                INSERT INTO content.promotion_display_locations (promotion_id, location_code, sort_order, created_by)
                VALUES (p_id, v_item ->> 'locationCode', COALESCE((v_item ->> 'sortOrder')::INTEGER, 0), p_user_id);
            END LOOP;
        END IF;
    END IF;
END;
$$;

COMMENT ON FUNCTION content.promotion_update(INTEGER, INTEGER, NUMERIC, NUMERIC, TIMESTAMP, TIMESTAMP, INTEGER, BOOLEAN, BOOLEAN, JSONB, JSONB, JSONB, JSONB, JSONB, INTEGER) IS 'Update promotion with all sub-records using delete+insert semantics.';
