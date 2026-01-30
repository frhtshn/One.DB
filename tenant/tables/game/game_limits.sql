-- =============================================
-- Tablo: game.game_limits
-- Açıklama: Oyun bahis limitleri
-- Oyun + Currency bazlı bahis limitleri
-- Her oyun-currency kombinasyonu için ayrı kayıt
-- =============================================

DROP TABLE IF EXISTS game.game_limits CASCADE;

CREATE TABLE game.game_limits (
    id BIGSERIAL PRIMARY KEY,

    -- Oyun referansı
    game_id BIGINT NOT NULL,                                        -- Core DB'deki oyun ID (catalog.games.id)

    -- Para birimi
    currency_code CHAR(3) NOT NULL,                                 -- Para birimi kodu: TRY, USD, EUR

    -- Bahis limitleri
    min_bet DECIMAL(18,8) NOT NULL,                                 -- Minimum bahis tutarı
    max_bet DECIMAL(18,8) NOT NULL,                                 -- Maksimum bahis tutarı
    default_bet DECIMAL(18,8),                                      -- Varsayılan bahis tutarı
    max_win DECIMAL(18,8),                                          -- Maksimum kazanç limiti (opsiyonel)

    -- Audit
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now()
);

COMMENT ON TABLE game.game_limits IS 'Currency-specific bet limits for each game. Linked to game_settings via game_id';
