-- ================================================================
-- PUBLIC_GAME_LIST: Oyuncu için oyun listesi (frontend)
-- Zorunlu filtreler: is_enabled=TRUE, is_visible=TRUE
-- Shadow mode: shadow oyunlar yalnızca test oyuncularına görünür
-- p_section_code: belirli lobi bölümüne göre filtrele (NULL = tümü)
-- Cursor pagination: (display_order, game_id) bazlı
-- Her oyuna ait aktif etiketler de dahil edilir
-- ================================================================

DROP FUNCTION IF EXISTS game.get_public_game_list(BIGINT[], BIGINT, VARCHAR, VARCHAR, TEXT, INTEGER, INTEGER, BIGINT);

CREATE OR REPLACE FUNCTION game.get_public_game_list(
    p_provider_ids  BIGINT[]        DEFAULT NULL,   -- Backend'den aktif provider ID'leri
    p_player_id     BIGINT          DEFAULT NULL,   -- Shadow mode kontrolü (NULL = misafir)
    p_section_code  VARCHAR(100)    DEFAULT NULL,   -- Lobi bölümü kodu (NULL = tüm oyunlar)
    p_game_type     VARCHAR(50)     DEFAULT NULL,   -- slots, live_casino, table_games vb.
    p_search        TEXT            DEFAULT NULL,   -- Oyun adı / kodu arama
    p_limit         INTEGER         DEFAULT 24,
    p_cursor_order  INTEGER         DEFAULT NULL,   -- Cursor pagination başlangıç noktası
    p_cursor_id     BIGINT          DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_is_shadow_tester  BOOLEAN := FALSE;
    v_section_id        BIGINT;
    v_items             JSONB;
    v_last_order        INTEGER;
    v_last_id           BIGINT;
    v_has_more          BOOLEAN;
BEGIN
    -- Shadow tester kontrolü
    IF p_player_id IS NOT NULL THEN
        SELECT EXISTS(
            SELECT 1 FROM auth.shadow_testers WHERE player_id = p_player_id
        ) INTO v_is_shadow_tester;
    END IF;

    -- Section kodu verilmişse ID'yi al
    IF p_section_code IS NOT NULL THEN
        SELECT id INTO v_section_id
        FROM game.lobby_sections
        WHERE code = p_section_code AND is_active = TRUE;
        -- Bölüm bulunamazsa boş sonuç döndür
        IF v_section_id IS NULL THEN
            RETURN jsonb_build_object('items', '[]'::JSONB, 'hasMore', FALSE,
                                      'nextCursorOrder', NULL, 'nextCursorId', NULL);
        END IF;
    END IF;

    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'gameId',           sub.game_id,
            'providerId',       sub.provider_id,
            'providerCode',     sub.provider_code,
            'externalGameId',   sub.external_game_id,
            'gameCode',         sub.game_code,
            'gameName',         COALESCE(sub.custom_name, sub.game_name),
            'studio',           sub.studio,
            'gameType',         sub.game_type,
            'gameSubtype',      sub.game_subtype,
            'categories',       sub.categories,
            'tags',             sub.tags,
            'rtp',              sub.rtp,
            'volatility',       sub.volatility,
            'thumbnailUrl',     COALESCE(sub.custom_thumbnail_url, sub.thumbnail_url),
            'hasDemo',          sub.has_demo,
            'hasJackpot',       sub.has_jackpot,
            'hasBonusBuy',      sub.has_bonus_buy,
            'isMobile',         sub.is_mobile,
            'isDesktop',        sub.is_desktop,
            'isFeatured',       sub.is_featured,
            'displayOrder',     sub.display_order,
            'popularityScore',  sub.popularity_score,
            -- Aktif etiketler (new, hot, exclusive vb.)
            'labels', COALESCE((
                SELECT jsonb_agg(jsonb_build_object(
                    'labelType',  gl.label_type,
                    'labelColor', gl.label_color
                ))
                FROM game.game_labels gl
                WHERE gl.game_id = sub.game_id
                  AND gl.is_active = TRUE
                  AND (gl.expires_at IS NULL OR gl.expires_at > NOW())
            ), '[]'::JSONB)
        ) ORDER BY sub.display_order ASC, sub.game_id ASC
    ), '[]'::JSONB)
    INTO v_items
    FROM (
        SELECT gs.*
        FROM game.game_settings gs
        -- Lobi bölümü filtresi (section_type=manual için inner join, auto_* için backend çağrısı yok)
        LEFT JOIN game.lobby_section_games lsg
            ON v_section_id IS NOT NULL
           AND lsg.lobby_section_id = v_section_id
           AND lsg.game_id = gs.game_id
           AND lsg.is_active = TRUE
        WHERE gs.is_enabled = TRUE
          AND gs.is_visible = TRUE
          -- Shadow mode: shadow oyunlar yalnızca test oyuncularına
          AND (gs.rollout_status = 'production' OR v_is_shadow_tester = TRUE)
          -- Provider filtresi
          AND (p_provider_ids IS NULL OR gs.provider_id = ANY(p_provider_ids))
          -- Oyun tipi filtresi
          AND (p_game_type IS NULL OR gs.game_type = UPPER(TRIM(p_game_type)))
          -- Arama filtresi
          AND (p_search IS NULL
               OR gs.game_name ILIKE '%' || p_search || '%'
               OR gs.game_code ILIKE '%' || p_search || '%'
               OR gs.custom_name ILIKE '%' || p_search || '%')
          -- Bölüm filtresi
          AND (v_section_id IS NULL OR lsg.id IS NOT NULL)
          -- Cursor pagination
          AND (p_cursor_order IS NULL OR p_cursor_id IS NULL
               OR (gs.display_order, gs.game_id) > (p_cursor_order, p_cursor_id))
        ORDER BY gs.display_order ASC, gs.game_id ASC
        LIMIT p_limit + 1
    ) sub;

    -- has_more kontrolü
    v_has_more := jsonb_array_length(v_items) > p_limit;
    IF v_has_more THEN
        v_items := v_items - p_limit;
    END IF;

    -- Sonraki cursor
    IF jsonb_array_length(v_items) > 0 THEN
        v_last_order := ((v_items -> (jsonb_array_length(v_items) - 1)) ->> 'displayOrder')::INTEGER;
        v_last_id    := ((v_items -> (jsonb_array_length(v_items) - 1)) ->> 'gameId')::BIGINT;
    END IF;

    RETURN jsonb_build_object(
        'items',            v_items,
        'hasMore',          v_has_more,
        'nextCursorOrder',  v_last_order,
        'nextCursorId',     v_last_id
    );
END;
$$;

COMMENT ON FUNCTION game.get_public_game_list(BIGINT[], BIGINT, VARCHAR, VARCHAR, TEXT, INTEGER, INTEGER, BIGINT) IS 'Player-facing game list. Forces is_enabled=TRUE and is_visible=TRUE. Supports shadow mode (test players see shadow-rollout games), lobby section filter, game type filter, text search, and cursor pagination. Includes active labels per game.';
