-- ================================================================
-- ANNOUNCEMENT_BAR_UPSERT: Duyuru çubuğu ekle / güncelle
-- code alanı üzerinden UPSERT yapılır
-- ================================================================

DROP FUNCTION IF EXISTS presentation.upsert_announcement_bar(VARCHAR, TIMESTAMPTZ, TIMESTAMPTZ, VARCHAR, VARCHAR[], SMALLINT, VARCHAR, VARCHAR, BOOLEAN, INTEGER);

CREATE OR REPLACE FUNCTION presentation.upsert_announcement_bar(
    p_code              VARCHAR(100),
    p_starts_at         TIMESTAMPTZ     DEFAULT NULL,
    p_ends_at           TIMESTAMPTZ     DEFAULT NULL,
    p_target_audience   VARCHAR(20)     DEFAULT 'all',
    p_country_codes     VARCHAR(2)[]    DEFAULT '{}',
    p_priority          SMALLINT        DEFAULT 0,
    p_bg_color          VARCHAR(7)      DEFAULT NULL,
    p_text_color        VARCHAR(7)      DEFAULT NULL,
    p_is_dismissible    BOOLEAN         DEFAULT TRUE,
    p_user_id           INTEGER         DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_id BIGINT;
BEGIN
    IF p_code IS NULL OR TRIM(p_code) = '' THEN
        RAISE EXCEPTION 'error.announcement-bar.code-required';
    END IF;
    IF p_target_audience NOT IN ('all', 'guest', 'logged_in') THEN
        RAISE EXCEPTION 'error.announcement-bar.invalid-audience';
    END IF;
    IF p_ends_at IS NOT NULL AND p_starts_at IS NOT NULL AND p_ends_at <= p_starts_at THEN
        RAISE EXCEPTION 'error.announcement-bar.ends-before-starts';
    END IF;

    INSERT INTO presentation.announcement_bars (
        code, starts_at, ends_at, target_audience, country_codes,
        priority, bg_color, text_color, is_dismissible, created_by, updated_by
    )
    VALUES (
        TRIM(p_code), p_starts_at, p_ends_at,
        COALESCE(p_target_audience, 'all'), COALESCE(p_country_codes, '{}'),
        COALESCE(p_priority, 0), p_bg_color, p_text_color,
        COALESCE(p_is_dismissible, TRUE), p_user_id, p_user_id
    )
    ON CONFLICT (code) DO UPDATE SET
        starts_at       = EXCLUDED.starts_at,
        ends_at         = EXCLUDED.ends_at,
        target_audience = EXCLUDED.target_audience,
        country_codes   = EXCLUDED.country_codes,
        priority        = EXCLUDED.priority,
        bg_color        = EXCLUDED.bg_color,
        text_color      = EXCLUDED.text_color,
        is_dismissible  = EXCLUDED.is_dismissible,
        is_active       = TRUE,
        updated_by      = EXCLUDED.updated_by,
        updated_at      = NOW()
    RETURNING id INTO v_id;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION presentation.upsert_announcement_bar(VARCHAR, TIMESTAMPTZ, TIMESTAMPTZ, VARCHAR, VARCHAR[], SMALLINT, VARCHAR, VARCHAR, BOOLEAN, INTEGER) IS 'Insert or update an announcement bar by code. target_audience must be all/guest/logged_in. Returns the bar ID.';
