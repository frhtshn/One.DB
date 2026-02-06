-- =============================================
-- Tablo: game.game_hourly_stats
-- Açıklama: Oyuncu bazlı oyun aktivitelerinin saatlik JSONB özeti.
-- Her oyun için ayrı satır yerine (row-based), tek satırda JSONB (document-based)
-- içinde detaylar tutularak satır sayısı %90+ azaltılır.
-- =============================================

DROP TABLE IF EXISTS game.game_hourly_stats CASCADE;

CREATE TABLE game.game_hourly_stats (
    id bigserial,                              -- Benzersiz kayıt ID
    period_hour timestamp with time zone NOT NULL,         -- İlgili saat

    -- Temel Bilgiler
    player_id bigint NOT NULL,                             -- Oyuncu ID
    wallet_id bigint NOT NULL,                             -- Cüzdan ID
    currency char(3) NOT NULL,                             -- Para birimi

    -- Agregasyon (Tüm oyunların toplamı)
    total_bet numeric(18, 8) DEFAULT 0,
    total_win numeric(18, 8) DEFAULT 0,
    total_count int DEFAULT 0,

    -- Oyun Detayları (JSONB)
    -- Key: GameID veya GameCode
    -- Value: { "bet": 100, "win": 0, "count": 2, "provider_id": 5, "category": "SLOT" }
    -- Örnek:
    -- {
    --   "1001": {"bet": 50, "win": 100, "c": 5, "p": 1, "t": "SLOT"},
    --   "2055": {"bet": 20, "win": 0,   "c": 1, "p": 2, "t": "LIVE"}
    -- }
    game_details jsonb DEFAULT '{}'::jsonb,

    -- Provider Bazlı Özet (Hızlı raporlama için)
    -- { "1": {"bet": 50, "win": 100}, "2": {"bet": 20, "win": 0} }
    provider_stats jsonb DEFAULT '{}'::jsonb,

    -- Meta
    updated_at timestamp without time zone,

    PRIMARY KEY (id, period_hour)                              -- Partition key PK'ya dahil
) PARTITION BY RANGE (period_hour);

-- Indexes moved to indexes/game.sql

CREATE TABLE game.game_hourly_stats_default PARTITION OF game.game_hourly_stats DEFAULT;

COMMENT ON TABLE game.game_hourly_stats IS 'Consolidated hourly game stats per player using JSONB map for games to reduce row count. Partitioned monthly by period_hour.';
