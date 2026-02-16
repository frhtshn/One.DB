-- ================================================================
-- GAME_SETTINGS_LIST: Lobi oyun listesi (cursor pagination)
-- ================================================================
-- p_provider_ids: Backend core'dan aktif provider ID'lerini geçirir.
-- NULL ise tüm oyunlar (BO admin görünümü).
-- Shadow mode filtresi: shadow oyunlar sadece test oyuncularına.
-- Cursor pagination: (display_order, id) bazlı, OFFSET yok.
-- Auth-agnostic.
-- ================================================================

DROP FUNCTION IF EXISTS game.game_settings_list(BIGINT[], BIGINT, VARCHAR, BOOLEAN, BOOLEAN, TEXT, INTEGER, INTEGER, BIGINT);

CREATE OR REPLACE FUNCTION game.game_settings_list(
    p_provider_ids BIGINT[] DEFAULT NULL,
    p_player_id BIGINT DEFAULT NULL,
    p_game_type VARCHAR(50) DEFAULT NULL,
    p_is_enabled BOOLEAN DEFAULT NULL,
    p_is_visible BOOLEAN DEFAULT NULL,
    p_search TEXT DEFAULT NULL,
    p_limit INTEGER DEFAULT 50,
    p_cursor_order INTEGER DEFAULT NULL,
    p_cursor_id BIGINT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_items JSONB;
    v_last_order INTEGER;
    v_last_id BIGINT;
    v_has_more BOOLEAN;
    v_is_shadow_tester BOOLEAN := false;
BEGIN
    -- Shadow tester kontrolü (player_id verilmişse)
    IF p_player_id IS NOT NULL THEN
        SELECT EXISTS(
            SELECT 1 FROM auth.shadow_testers WHERE player_id = p_player_id
        ) INTO v_is_shadow_tester;
    END IF;

    -- Oyun listesi (subquery ile LIMIT uygulanır)
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'gameId', sub.game_id,
            'providerId', sub.provider_id,
            'providerCode', sub.provider_code,
            'externalGameId', sub.external_game_id,
            'gameCode', sub.game_code,
            'gameName', COALESCE(sub.custom_name, sub.game_name),
            'studio', sub.studio,
            'gameType', sub.game_type,
            'gameSubtype', sub.game_subtype,
            'categories', sub.categories,
            'tags', sub.tags,
            'rtp', sub.rtp,
            'volatility', sub.volatility,
            'thumbnailUrl', COALESCE(sub.custom_thumbnail_url, sub.thumbnail_url),
            'features', sub.features,
            'hasDemo', sub.has_demo,
            'hasJackpot', sub.has_jackpot,
            'hasBonusBuy', sub.has_bonus_buy,
            'isMobile', sub.is_mobile,
            'isDesktop', sub.is_desktop,
            'isFeatured', sub.is_featured,
            'displayOrder', sub.display_order,
            'rolloutStatus', sub.rollout_status,
            'popularityScore', sub.popularity_score,
            'playCount', sub.play_count
        ) ORDER BY sub.display_order ASC, sub.id ASC
    ), '[]'::jsonb)
    INTO v_items
    FROM (
        SELECT gs.*
        FROM game.game_settings gs
        WHERE (p_provider_ids IS NULL OR gs.provider_id = ANY(p_provider_ids))
          AND (p_game_type IS NULL OR gs.game_type = UPPER(TRIM(p_game_type)))
          AND (p_is_enabled IS NULL OR gs.is_enabled = p_is_enabled)
          AND (p_is_visible IS NULL OR gs.is_visible = p_is_visible)
          AND (p_search IS NULL OR
               gs.game_name ILIKE '%' || p_search || '%' OR
               gs.game_code ILIKE '%' || p_search || '%' OR
               gs.custom_name ILIKE '%' || p_search || '%')
          -- Shadow mode filtresi
          AND (gs.rollout_status = 'production' OR v_is_shadow_tester = true)
          -- Cursor pagination
          AND (p_cursor_order IS NULL OR p_cursor_id IS NULL OR
               (gs.display_order, gs.id) > (p_cursor_order, p_cursor_id))
        ORDER BY gs.display_order ASC, gs.id ASC
        LIMIT p_limit + 1
    ) sub;

    -- has_more kontrolü (limit+1 kayıt geldiyse daha var)
    v_has_more := jsonb_array_length(v_items) > p_limit;

    -- Fazla kaydı kırp (son elemanı çıkar)
    IF v_has_more THEN
        v_items := v_items - p_limit;
    END IF;

    -- Son kaydın cursor bilgileri
    IF jsonb_array_length(v_items) > 0 THEN
        v_last_order := ((v_items->(jsonb_array_length(v_items) - 1))->>'displayOrder')::INTEGER;
        v_last_id := ((v_items->(jsonb_array_length(v_items) - 1))->>'gameId')::BIGINT;
    END IF;

    RETURN jsonb_build_object(
        'items', v_items,
        'nextCursorOrder', v_last_order,
        'nextCursorId', v_last_id,
        'hasMore', v_has_more
    );
END;
$$;

COMMENT ON FUNCTION game.game_settings_list IS 'Returns game list with cursor pagination (display_order, id). Supports provider filtering, shadow mode (testers see shadow games), and text search. Auth-agnostic.';
