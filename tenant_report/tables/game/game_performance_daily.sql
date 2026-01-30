-- =============================================
-- Tablo: game.game_performance_daily
-- Açıklama: Oyun ve Sağlayıcı bazlı GÜNLÜK performans raporu.
-- RTP analizi, popülerlik ölçümü ve provider mutabakatı için kullanılır.
-- =============================================

DROP TABLE IF EXISTS game.game_performance_daily CASCADE;

CREATE TABLE game.game_performance_daily (
    id bigserial PRIMARY KEY,                              -- Benzersiz kayıt ID
    report_date date NOT NULL,                             -- Rapor tarihi

    -- Kırılımlar
    game_id bigint,                                        -- Oyun ID (NULL ise Provider toplamıdır)
    provider_id bigint NOT NULL,                           -- Sağlayıcı ID
    currency char(3) NOT NULL,

    -- Oyun Metrikleri
    total_rounds bigint DEFAULT 0,                         -- Toplam spin/el sayısı
    total_bet numeric(18, 8) DEFAULT 0,
    total_win numeric(18, 8) DEFAULT 0,
    total_ggr numeric(18, 8) GENERATED ALWAYS AS (total_bet - total_win) STORED,

    -- Analitik
    unique_players int DEFAULT 0,                          -- Oyunu oynayan tekil kişi sayısı
    rtp_actual numeric(5,2) DEFAULT 0,                     -- Gerçekleşen RTP (Return to Player) %

    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone

    -- Constraint moved to constraints/game.sql
);

-- Indexes moved to indexes/game.sql

COMMENT ON TABLE game.game_performance_daily IS 'Daily performance stats per game and provider for invoice reconciliation and RTP analysis';
