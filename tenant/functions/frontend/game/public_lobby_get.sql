-- ================================================================
-- PUBLIC_LOBBY_GET: Oyuncu lobi yapısını döndür (frontend)
-- Aktif bölümler + tercih edilen dil çevirisi + game_id listesi
-- manual bölümler → kuratörlük yapılmış game_id'ler
-- auto_* bölümler → boş game_ids (backend core DB'den doldurur)
-- ================================================================

DROP FUNCTION IF EXISTS game.get_public_lobby(VARCHAR, BIGINT);

CREATE OR REPLACE FUNCTION game.get_public_lobby(
    p_language_code VARCHAR(5)  DEFAULT 'en',
    p_player_id     BIGINT      DEFAULT NULL   -- Shadow tester kontrolü için
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_is_shadow_tester BOOLEAN := FALSE;
BEGIN
    -- Shadow tester kontrolü
    IF p_player_id IS NOT NULL THEN
        SELECT EXISTS(
            SELECT 1 FROM auth.shadow_testers WHERE player_id = p_player_id
        ) INTO v_is_shadow_tester;
    END IF;

    RETURN COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'id',           s.id,
                'code',         s.code,
                'sectionType',  s.section_type,
                'maxItems',     s.max_items,
                'displayOrder', s.display_order,
                'linkUrl',      s.link_url,
                'title',        COALESCE(
                    (SELECT t.title FROM game.lobby_section_translations t
                     WHERE t.lobby_section_id = s.id AND t.language_code = p_language_code LIMIT 1),
                    (SELECT t.title FROM game.lobby_section_translations t
                     WHERE t.lobby_section_id = s.id AND t.language_code = 'en' LIMIT 1)
                ),
                'subtitle',     COALESCE(
                    (SELECT t.subtitle FROM game.lobby_section_translations t
                     WHERE t.lobby_section_id = s.id AND t.language_code = p_language_code LIMIT 1),
                    (SELECT t.subtitle FROM game.lobby_section_translations t
                     WHERE t.lobby_section_id = s.id AND t.language_code = 'en' LIMIT 1)
                ),
                -- manual bölümler için kuratörlük yapılmış game_id listesi
                -- auto_* bölümler için boş array (backend doldurur)
                'gameIds',      CASE
                    WHEN s.section_type = 'manual' THEN COALESCE((
                        SELECT jsonb_agg(lg.game_id ORDER BY lg.display_order, lg.id)
                        FROM game.lobby_section_games lg
                        WHERE lg.lobby_section_id = s.id
                          AND lg.is_active = TRUE
                        -- Shadow tester değilse shadow oyunları gizle (backend kontrol eder)
                    ), '[]'::JSONB)
                    ELSE '[]'::JSONB
                END
            ) ORDER BY s.display_order, s.id
        )
        FROM game.lobby_sections s
        WHERE s.is_active = TRUE
    ), '[]'::JSONB);
END;
$$;

COMMENT ON FUNCTION game.get_public_lobby(VARCHAR, BIGINT) IS 'Returns active lobby sections with translations and game_ids for frontend rendering. Manual sections include curated game_id arrays; auto_* sections return empty arrays to be filled by backend from core DB game catalog.';
