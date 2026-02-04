-- ================================================================
-- SLIDE_UPDATE: Slide güncelle (Backoffice)
-- ================================================================
-- NOT: Yetki kontrolü Core DB'de yapılır (user_assert_access_tenant)
-- Partial update destekler (NULL = değiştirme)
-- ================================================================

DROP FUNCTION IF EXISTS content.slide_update(
    INTEGER, INTEGER, INTEGER, VARCHAR, INTEGER, INTEGER,
    VARCHAR, VARCHAR, VARCHAR, VARCHAR,
    TIMESTAMP, TIMESTAMP,
    INTEGER[], CHAR(2)[], CHAR(2)[],
    INTEGER, VARCHAR, BOOLEAN, INTEGER
);

CREATE OR REPLACE FUNCTION content.slide_update(
    p_id INTEGER,
    p_placement_id INTEGER DEFAULT NULL,
    p_category_id INTEGER DEFAULT NULL,
    p_code VARCHAR(50) DEFAULT NULL,
    p_sort_order INTEGER DEFAULT NULL,
    p_priority INTEGER DEFAULT NULL,
    -- Link
    p_link_url VARCHAR(500) DEFAULT NULL,
    p_link_target VARCHAR(20) DEFAULT NULL,
    p_link_type VARCHAR(20) DEFAULT NULL,
    p_link_reference VARCHAR(100) DEFAULT NULL,
    -- Tarih
    p_start_date TIMESTAMP DEFAULT NULL,
    p_end_date TIMESTAMP DEFAULT NULL,
    -- Hedefleme
    p_segment_ids INTEGER[] DEFAULT NULL,
    p_country_codes CHAR(2)[] DEFAULT NULL,
    p_excluded_country_codes CHAR(2)[] DEFAULT NULL,
    -- Görüntüleme
    p_display_duration INTEGER DEFAULT NULL,
    p_animation_type VARCHAR(30) DEFAULT NULL,
    -- Durum
    p_is_active BOOLEAN DEFAULT NULL,
    -- Audit
    p_operator_id INTEGER DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Varlık kontrolü
    IF NOT EXISTS(SELECT 1 FROM content.slides WHERE id = p_id AND is_deleted = FALSE) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.slide.not-found';
    END IF;

    -- Kod benzersizlik kontrolü
    IF p_code IS NOT NULL AND EXISTS(
        SELECT 1 FROM content.slides WHERE code = p_code AND id != p_id AND is_deleted = FALSE
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.slide.code-exists';
    END IF;

    -- Placement kontrolü
    IF p_placement_id IS NOT NULL AND NOT EXISTS(
        SELECT 1 FROM content.slide_placements WHERE id = p_placement_id
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.slide-placement.not-found';
    END IF;

    -- Update
    UPDATE content.slides
    SET
        placement_id = COALESCE(p_placement_id, placement_id),
        category_id = COALESCE(p_category_id, category_id),
        code = COALESCE(p_code, code),
        sort_order = COALESCE(p_sort_order, sort_order),
        priority = COALESCE(p_priority, priority),
        link_url = COALESCE(p_link_url, link_url),
        link_target = COALESCE(p_link_target, link_target),
        link_type = COALESCE(p_link_type, link_type),
        link_reference = COALESCE(p_link_reference, link_reference),
        start_date = COALESCE(p_start_date, start_date),
        end_date = COALESCE(p_end_date, end_date),
        segment_ids = COALESCE(p_segment_ids, segment_ids),
        country_codes = COALESCE(p_country_codes, country_codes),
        excluded_country_codes = COALESCE(p_excluded_country_codes, excluded_country_codes),
        display_duration = COALESCE(p_display_duration, display_duration),
        animation_type = COALESCE(p_animation_type, animation_type),
        is_active = COALESCE(p_is_active, is_active),
        updated_at = NOW(),
        updated_by = p_operator_id
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION content.slide_update IS 'Updates a slide. Partial update supported. Auth check done in Core DB.';
