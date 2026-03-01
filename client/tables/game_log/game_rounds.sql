-- =============================================
-- Tablo: game_log.game_rounds
-- Açıklama: Oyun turu/round detay logları
-- Her spin, el veya bahis bir round'dur
-- Yüksek hacim: per-client izolasyon
-- CLIENT_LOG DB - 30 gün retention (daily partition)
-- =============================================

DROP TABLE IF EXISTS game_log.game_rounds CASCADE;

CREATE TABLE game_log.game_rounds (
    id bigserial,

    -- Oyuncu ve oyun bilgileri
    player_id BIGINT NOT NULL,                           -- Oyuncu ID (client DB referans)
    game_code VARCHAR(100) NOT NULL,                     -- Oyun kodu: vs20olympgate, sweet_bonanza
    game_name VARCHAR(255),                              -- Oyun adı (denormalize, debug kolaylığı)
    provider_code VARCHAR(50) NOT NULL,                  -- Provider kodu: PRAGMATIC, EVOLUTION
    game_type VARCHAR(50),                               -- slot, live_casino, table_game, crash, virtual_sport

    -- Round tanımlayıcıları
    external_round_id VARCHAR(100) NOT NULL,             -- Provider'ın round ID'si
    external_session_id VARCHAR(100),                    -- Provider oturum ID'si
    parent_round_id VARCHAR(100),                        -- Üst round (bonus round bağlantısı)

    -- Finansal özet
    bet_amount DECIMAL(18,8) NOT NULL DEFAULT 0,         -- Toplam bahis tutarı
    win_amount DECIMAL(18,8) NOT NULL DEFAULT 0,         -- Toplam kazanç tutarı
    net_amount DECIMAL(18,8) NOT NULL DEFAULT 0,         -- Net sonuç (win - bet)
    jackpot_amount DECIMAL(18,8) DEFAULT 0,              -- Jackpot kazancı (varsa)
    currency_code VARCHAR(20) NOT NULL,                  -- Para birimi

    -- Round durumu
    round_status VARCHAR(20) NOT NULL DEFAULT 'open',    -- open, closed, cancelled, refunded
    is_free_round BOOLEAN NOT NULL DEFAULT false,        -- Freespin round'u mu
    is_bonus_round BOOLEAN NOT NULL DEFAULT false,       -- Bonus round'u mu
    bonus_award_id BIGINT,                               -- Bağlı bonus award (varsa)

    -- Round detayları (oyun tipine göre değişken)
    round_detail JSONB DEFAULT '{}',                     -- Slot: {symbols, paylines, multiplier, scatters}
                                                          -- Live: {dealer, table_id, seat, cards, result}
                                                          -- Crash: {crash_point, cash_out_at}
                                                          -- Tüm detaylar buraya JSONB olarak yazılır

    -- Zamanlama
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),       -- Round başlangıcı
    ended_at TIMESTAMPTZ,                                -- Round bitişi
    duration_ms INTEGER,                                 -- Round süresi (milisaniye)

    -- Transaction referansları (client.transactions ile korelasyon)
    bet_transaction_id BIGINT,                           -- Bahis transaction ID
    win_transaction_id BIGINT,                           -- Kazanç transaction ID

    -- Platform bilgisi
    device_type VARCHAR(20),                             -- desktop, mobile, tablet
    ip_address INET,                                     -- Oyuncu IP'si

    created_at TIMESTAMP NOT NULL DEFAULT now(),
    PRIMARY KEY (id, created_at)
) PARTITION BY RANGE (created_at);

CREATE TABLE game_log.game_rounds_default PARTITION OF game_log.game_rounds DEFAULT;

COMMENT ON TABLE game_log.game_rounds IS 'Game round/spin detail logs per player. High-volume table isolated per-client. Stores financial summary, round metadata, and game-specific details in JSONB. Partitioned daily by created_at. Retention: 30 days.';
