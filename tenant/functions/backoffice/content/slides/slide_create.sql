-- ================================================================
-- SLIDE_CREATE: Yeni slide oluştur (Backoffice)
-- ================================================================
-- NOT: Yetki kontrolü Core DB'de yapılır (user_assert_access_tenant)
-- p_operator_id: Core DB user ID (audit için)
-- ================================================================

DROP FUNCTION IF EXISTS content.slide_create(
    INTEGER, INTEGER, VARCHAR, INTEGER, INTEGER,
    VARCHAR, VARCHAR, VARCHAR, VARCHAR,
    TIMESTAMP, TIMESTAMP,
    INTEGER[], CHAR(2)[], CHAR(2)[],
    INTEGER, VARCHAR, INTEGER
);

CREATE OR REPLACE FUNCTION content.slide_create(
    p_placement_id INTEGER,
    p_category_id INTEGER DEFAULT NULL,
    p_code VARCHAR(50) DEFAULT NULL,
    p_sort_order INTEGER DEFAULT 0,
    p_priority INTEGER DEFAULT 0,
    -- Link
    p_link_url VARCHAR(500) DEFAULT NULL,
    p_link_target VARCHAR(20) DEFAULT '_self',
    p_link_type VARCHAR(20) DEFAULT 'url',
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
    p_animation_type VARCHAR(30) DEFAULT 'fade',
    -- Audit
    p_operator_id INTEGER DEFAULT NULL
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_id INTEGER;
BEGIN
    -- Placement kontrolü
    IF NOT EXISTS(SELECT 1 FROM content.slide_placements WHERE id = p_placement_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.slide-placement.not-found';
    END IF;

    -- Kod benzersizlik kontrolü (varsa)
    IF p_code IS NOT NULL AND EXISTS(
        SELECT 1 FROM content.slides WHERE code = p_code AND is_deleted = FALSE
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.slide.code-exists';
    END IF;

    -- Insert
    INSERT INTO content.slides (
        placement_id, category_id, code, sort_order, priority,
        link_url, link_target, link_type, link_reference,
        start_date, end_date,
        segment_ids, country_codes, excluded_country_codes,
        display_duration, animation_type,
        is_active, created_at, created_by
    )
    VALUES (
        p_placement_id, p_category_id, p_code, p_sort_order, p_priority,
        p_link_url, p_link_target, p_link_type, p_link_reference,
        p_start_date, p_end_date,
        p_segment_ids, p_country_codes, p_excluded_country_codes,
        p_display_duration, p_animation_type,
        TRUE, NOW(), p_operator_id
    )
    RETURNING id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION content.slide_create IS 'Creates a new slide. Auth check done in Core DB. p_operator_id is Core DB user ID.';
