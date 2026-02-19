-- ================================================================
-- GAME_SETTINGS_GET: Tekil oyun detay (game open flow)
-- ================================================================
-- Player oyun açarken backend bu fonksiyonu çağırır.
-- provider_id + external_game_id ile Gateway'e gRPC isteği yapar.
-- Auth-agnostic (cross-DB auth pattern).
-- ================================================================

DROP FUNCTION IF EXISTS game.game_settings_get(BIGINT);

CREATE OR REPLACE FUNCTION game.game_settings_get(
    p_game_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
BEGIN
    IF p_game_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.game.id-required';
    END IF;

    SELECT jsonb_build_object(
        'gameId', gs.game_id,
        'providerId', gs.provider_id,
        'providerCode', gs.provider_code,
        'externalGameId', gs.external_game_id,
        'gameCode', gs.game_code,
        'gameName', gs.game_name,
        'studio', gs.studio,
        'gameType', gs.game_type,
        'gameSubtype', gs.game_subtype,
        'categories', gs.categories,
        'tags', gs.tags,
        'rtp', gs.rtp,
        'rtpVariant', gs.rtp_variant,
        'volatility', gs.volatility,
        'maxMultiplier', gs.max_multiplier,
        'paylines', gs.paylines,
        'thumbnailUrl', gs.thumbnail_url,
        'backgroundUrl', gs.background_url,
        'logoUrl', gs.logo_url,
        'customThumbnailUrl', gs.custom_thumbnail_url,
        'features', gs.features,
        'hasDemo', gs.has_demo,
        'hasJackpot', gs.has_jackpot,
        'jackpotType', gs.jackpot_type,
        'hasBonusBuy', gs.has_bonus_buy,
        'isMobile', gs.is_mobile,
        'isDesktop', gs.is_desktop,
        'isEnabled', gs.is_enabled,
        'isVisible', gs.is_visible,
        'isFeatured', gs.is_featured,
        'displayOrder', gs.display_order,
        'customName', gs.custom_name,
        'customCategories', gs.custom_categories,
        'customTags', gs.custom_tags,
        'allowedPlatforms', gs.allowed_platforms,
        'blockedCountries', gs.blocked_countries,
        'allowedCountries', gs.allowed_countries,
        'rolloutStatus', gs.rollout_status,
        'availableFrom', gs.available_from,
        'availableUntil', gs.available_until,
        'coreSyncedAt', gs.core_synced_at
    )
    INTO v_result
    FROM game.game_settings gs
    WHERE gs.game_id = p_game_id;

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.game.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION game.game_settings_get(BIGINT) IS 'Returns single game detail for game open flow. Backend uses provider_id + external_game_id for Gateway gRPC request. Auth-agnostic.';
