-- =============================================
-- Game Limits (Oyun Limitleri)
-- Oyun + Currency bazlı bahis limitleri
-- Her oyun-currency kombinasyonu için ayrı kayıt
-- =============================================

DROP TABLE IF EXISTS game.game_limits CASCADE;

CREATE TABLE game.game_limits (
    id bigserial PRIMARY KEY,

    -- Oyun referansı (game_settings ile aynı game_id)
    game_id bigint NOT NULL,                      -- Core DB'deki oyun ID

    -- Para birimi
    currency_code character(3) NOT NULL,          -- Para birimi kodu: TRY, USD, EUR

    -- Bahis limitleri
    min_bet decimal(18,2) NOT NULL,               -- Minimum bahis tutarı
    max_bet decimal(18,2) NOT NULL,               -- Maksimum bahis tutarı
    max_win decimal(18,2),                        -- Maksimum kazanç limiti (opsiyonel)

    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()


);

COMMENT ON TABLE game.game_limits IS 'Currency-specific bet limits for each game. Linked to game_settings via game_id.';
