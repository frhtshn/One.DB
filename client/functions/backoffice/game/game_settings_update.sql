-- ================================================================
-- GAME_SETTINGS_UPDATE: Client customization güncelleme
-- ================================================================
-- COALESCE pattern (NULL = mevcut değeri koru).
-- Sadece client-editable alanları günceller.
-- Auth-agnostic (cross-DB auth pattern).
-- ================================================================

DROP FUNCTION IF EXISTS game.game_settings_update(
    BIGINT, VARCHAR, VARCHAR, VARCHAR(50)[], VARCHAR(50)[],
    INTEGER, BOOLEAN, BOOLEAN, VARCHAR,
    VARCHAR(20)[], CHAR(2)[], CHAR(2)[],
    TIMESTAMP, TIMESTAMP
);

CREATE OR REPLACE FUNCTION game.game_settings_update(
    p_game_id BIGINT,
    p_custom_name VARCHAR(255) DEFAULT NULL,
    p_custom_thumbnail_url VARCHAR(500) DEFAULT NULL,
    p_custom_categories VARCHAR(50)[] DEFAULT NULL,
    p_custom_tags VARCHAR(50)[] DEFAULT NULL,
    p_display_order INTEGER DEFAULT NULL,
    p_is_visible BOOLEAN DEFAULT NULL,
    p_is_featured BOOLEAN DEFAULT NULL,
    p_rtp_variant VARCHAR(20) DEFAULT NULL,
    p_allowed_platforms VARCHAR(20)[] DEFAULT NULL,
    p_blocked_countries CHAR(2)[] DEFAULT NULL,
    p_allowed_countries CHAR(2)[] DEFAULT NULL,
    p_available_from TIMESTAMP DEFAULT NULL,
    p_available_until TIMESTAMP DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_game_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.game.id-required';
    END IF;

    UPDATE game.game_settings SET
        custom_name = COALESCE(p_custom_name, custom_name),
        custom_thumbnail_url = COALESCE(p_custom_thumbnail_url, custom_thumbnail_url),
        custom_categories = COALESCE(p_custom_categories, custom_categories),
        custom_tags = COALESCE(p_custom_tags, custom_tags),
        display_order = COALESCE(p_display_order, display_order),
        is_visible = COALESCE(p_is_visible, is_visible),
        is_featured = COALESCE(p_is_featured, is_featured),
        rtp_variant = COALESCE(p_rtp_variant, rtp_variant),
        allowed_platforms = COALESCE(p_allowed_platforms, allowed_platforms),
        blocked_countries = COALESCE(p_blocked_countries, blocked_countries),
        allowed_countries = COALESCE(p_allowed_countries, allowed_countries),
        available_from = COALESCE(p_available_from, available_from),
        available_until = COALESCE(p_available_until, available_until),
        updated_at = NOW()
    WHERE game_id = p_game_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.game.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION game.game_settings_update IS 'Updates client-editable game settings (custom_name, display_order, blocked_countries, etc). COALESCE pattern. Auth-agnostic.';
