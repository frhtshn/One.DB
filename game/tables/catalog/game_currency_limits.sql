-- =============================================
-- Tablo: catalog.game_currency_limits
-- Açıklama: Per-game, per-currency limit bilgileri
-- Gateway sync (API olan provider'lar) veya
-- BO admin (CSV/Excel import, manuel CRUD)
-- tarafından doldurulur.
-- catalog.games'deki min_bet/max_bet referans
-- olarak kalır, bu tablo detaylı limitleri tutar.
-- =============================================

DROP TABLE IF EXISTS catalog.game_currency_limits CASCADE;

CREATE TABLE catalog.game_currency_limits (
    id BIGSERIAL PRIMARY KEY,                                       -- Benzersiz limit kimliği
    game_id BIGINT NOT NULL,                                        -- Oyun ID (FK: catalog.games)
    currency_code VARCHAR(20) NOT NULL,                             -- Para birimi kodu: TRY, USD, BTC, ETH, DOGE
    currency_type SMALLINT NOT NULL DEFAULT 1,                      -- 1=Fiat, 2=Crypto
    min_bet DECIMAL(18,8) NOT NULL,                                 -- Minimum bahis
    max_bet DECIMAL(18,8) NOT NULL,                                 -- Maksimum bahis
    default_bet DECIMAL(18,8),                                      -- Varsayılan bahis
    max_win DECIMAL(18,8),                                          -- Maksimum kazanç
    is_active BOOLEAN NOT NULL DEFAULT true,                        -- Soft delete: provider artık desteklemiyorsa false
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),                  -- Oluşturulma zamanı
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()                   -- Güncellenme zamanı
);

COMMENT ON TABLE catalog.game_currency_limits IS 'Per-game, per-currency bet limits. Populated via gateway sync or BO admin import. Supports both fiat (currency_type=1) and crypto (currency_type=2).';
