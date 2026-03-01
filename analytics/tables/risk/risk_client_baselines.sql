-- =============================================
-- Tablo: risk.risk_tenant_baselines
-- Açıklama: Tenant bazlı özet istatistikler
-- Report Cluster yazar, RiskManager okur
-- =============================================

DROP TABLE IF EXISTS risk.risk_tenant_baselines CASCADE;

CREATE TABLE risk.risk_tenant_baselines (
    tenant_id               INT             NOT NULL,
    base_currency           VARCHAR(3)      NOT NULL DEFAULT '',

    -- Tenant seviyesi deposit/withdrawal ortalamaları
    avg_deposit             NUMERIC(18,2)   NOT NULL DEFAULT 0,
    deposit_stddev          NUMERIC(18,2)   NOT NULL DEFAULT 0,
    avg_withdrawal          NUMERIC(18,2)   NOT NULL DEFAULT 0,
    withdrawal_stddev       NUMERIC(18,2)   NOT NULL DEFAULT 0,
    total_players           INT             NOT NULL DEFAULT 0,
    avg_deposits_per_day    NUMERIC(10,4)   NOT NULL DEFAULT 0,

    updated_at              TIMESTAMPTZ     NOT NULL,

    PRIMARY KEY (tenant_id)
);

COMMENT ON TABLE risk.risk_tenant_baselines IS 'Per-tenant aggregate statistical baseline for risk analysis. Written by Report Cluster, read by RiskManager.';
