-- =============================================
-- Tablo: risk.risk_player_scores
-- Açıklama: RiskManager'ın ürettiği güncel risk skoru
-- RiskManager yazar, Backoffice Cluster okur
-- =============================================

DROP TABLE IF EXISTS risk.risk_player_scores CASCADE;

CREATE TABLE risk.risk_player_scores (
    client_id               INT             NOT NULL,
    player_id               BIGINT          NOT NULL,

    -- Güncel risk sonucu
    anomaly_score           NUMERIC(5,4)    NOT NULL DEFAULT 0,
    risk_level              VARCHAR(10)     NOT NULL DEFAULT 'low',     -- low, medium, high
    pattern_deviations      JSONB           NOT NULL DEFAULT '[]'::jsonb,
    zscore_details          JSONB           NOT NULL DEFAULT '{}'::jsonb,
    model_version           VARCHAR(50)     NOT NULL DEFAULT '',

    -- İstatistik
    high_risk_count         INT             NOT NULL DEFAULT 0,
    evaluation_count        INT             NOT NULL DEFAULT 0,

    -- Zaman damgaları
    evaluated_at            TIMESTAMPTZ     NOT NULL,
    first_evaluated_at      TIMESTAMPTZ     NOT NULL,

    PRIMARY KEY (client_id, player_id)
);

COMMENT ON TABLE risk.risk_player_scores IS 'Current risk evaluation scores produced by RiskManager. Written by RiskManager via UPSERT, read by Backoffice Cluster.';
