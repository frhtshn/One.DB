-- ================================================================
-- SLIDE_PLACEMENT_UPSERT: Yerleşim alanı oluştur/güncelle
-- ================================================================

DROP FUNCTION IF EXISTS content.slide_placement_upsert(INTEGER, VARCHAR, VARCHAR, VARCHAR, INTEGER, INTEGER, INTEGER, VARCHAR, INTEGER);

CREATE OR REPLACE FUNCTION content.slide_placement_upsert(
    p_id                INTEGER     DEFAULT NULL,
    p_code              VARCHAR(50) DEFAULT NULL,
    p_name              VARCHAR(100) DEFAULT NULL,
    p_description       VARCHAR(500) DEFAULT NULL,
    p_max_slides        INTEGER     DEFAULT 5,
    p_width             INTEGER     DEFAULT NULL,
    p_height            INTEGER     DEFAULT NULL,
    p_aspect_ratio      VARCHAR(10) DEFAULT NULL,
    p_user_id           INTEGER     DEFAULT NULL
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_id INTEGER;
BEGIN
    IF p_user_id IS NULL THEN RAISE EXCEPTION 'error.slide.user-id-required'; END IF;

    IF p_id IS NOT NULL THEN
        UPDATE content.slide_placements
        SET code         = COALESCE(p_code, code),
            name         = COALESCE(p_name, name),
            description  = COALESCE(p_description, description),
            max_slides   = COALESCE(p_max_slides, max_slides),
            width        = COALESCE(p_width, width),
            height       = COALESCE(p_height, height),
            aspect_ratio = COALESCE(p_aspect_ratio, aspect_ratio),
            updated_by   = p_user_id, updated_at = NOW()
        WHERE id = p_id
        RETURNING id INTO v_id;

        IF v_id IS NULL THEN RAISE EXCEPTION 'error.slide.placement-not-found'; END IF;
    ELSE
        IF p_code IS NULL OR p_code = '' THEN RAISE EXCEPTION 'error.slide.placement-code-required'; END IF;
        IF p_name IS NULL OR p_name = '' THEN RAISE EXCEPTION 'error.slide.placement-name-required'; END IF;

        INSERT INTO content.slide_placements (code, name, description, max_slides, width, height, aspect_ratio, created_by, updated_by)
        VALUES (p_code, p_name, p_description, COALESCE(p_max_slides, 5), p_width, p_height, p_aspect_ratio, p_user_id, p_user_id)
        RETURNING id INTO v_id;
    END IF;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION content.slide_placement_upsert(INTEGER, VARCHAR, VARCHAR, VARCHAR, INTEGER, INTEGER, INTEGER, VARCHAR, INTEGER) IS 'Create or update slide placement area with dimension recommendations.';
