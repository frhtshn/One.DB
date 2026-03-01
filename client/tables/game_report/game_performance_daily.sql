-- =============================================
-- Tablo: game_report.game_performance_daily
-- Açıklama: Oyun ve Sağlayıcı bazlı GÜNLÜK performans raporu.
-- RTP analizi, popülerlik ölçümü ve provider mutabakatı için kullanılır.
-- =============================================

DROP TABLE IF EXISTS game_report.game_performance_daily CASCADE;

CREATE TABLE game_report.game_performance_daily (
    id bigserial,                              -- Benzersiz kayıt ID
    report_date date NOT NULL,                             -- Rapor tarihi

    -- Kırılımlar
    game_id bigint,                                        -- Oyun ID (NULL ise Provider toplamıdır)
    provider_id bigint NOT NULL,                           -- Sağlayıcı ID
    currency varchar(20) NOT NULL,                          -- Para birimi (Fiat: TRY, Crypto: BTC)

    -- Oyun Metrikleri
    total_rounds bigint DEFAULT 0,                         -- Toplam spin/el sayısı
    total_bet numeric(18, 8) DEFAULT 0,
    total_win numeric(18, 8) DEFAULT 0,
    total_ggr numeric(18, 8) GENERATED ALWAYS AS (total_bet - total_win) STORED,

    -- Analitik
    unique_players int DEFAULT 0,                          -- Oyunu oynayan tekil kişi sayısı
    rtp_actual numeric(5,2) DEFAULT 0,                     -- Gerçekleşen RTP (Return to Player) %

    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone,

    PRIMARY KEY (id, report_date)                              -- Partition key PK'ya dahil
) PARTITION BY RANGE (report_date);

-- Indexes moved to indexes/game_report.sql

CREATE TABLE game_report.game_performance_daily_default PARTITION OF game_report.game_performance_daily DEFAULT;

COMMENT ON TABLE game_report.game_performance_daily IS 'Daily performance stats per game and provider for invoice reconciliation and RTP analysis. Partitioned monthly by report_date.';
