-- =============================================
-- Tablo: risk.risk_player_baselines
-- Açıklama: Oyuncu bazlı istatistiksel özet
-- Report Cluster yazar, RiskManager okur
-- Tüm tutarlar tenant base currency'sine normalize
-- =============================================

DROP TABLE IF EXISTS risk.risk_player_baselines CASCADE;

CREATE TABLE risk.risk_player_baselines (
    tenant_id               INT             NOT NULL,
    player_id               BIGINT          NOT NULL,

    -- Deposit / Withdrawal istatistikleri
    avg_deposit             NUMERIC(18,2)   NOT NULL DEFAULT 0,
    deposit_stddev          NUMERIC(18,2)   NOT NULL DEFAULT 0,
    avg_withdrawal          NUMERIC(18,2)   NOT NULL DEFAULT 0,
    withdrawal_stddev       NUMERIC(18,2)   NOT NULL DEFAULT 0,
    avg_deposits_per_day    NUMERIC(10,4)   NOT NULL DEFAULT 0,
    avg_withdrawals_per_day NUMERIC(10,4)   NOT NULL DEFAULT 0,
    avg_deposit_interval_sec INT            NOT NULL DEFAULT 0,
    deposit_interval_stddev INT             NOT NULL DEFAULT 0,
    deposit_count_24h       SMALLINT        NOT NULL DEFAULT 0,
    withdrawal_count_24h    SMALLINT        NOT NULL DEFAULT 0,
    last_deposit_ts         TIMESTAMPTZ     NULL,
    last_withdrawal_ts      TIMESTAMPTZ     NULL,
    transaction_count       INT             NOT NULL DEFAULT 0,

    -- Bonus istatistikleri
    avg_bonus_amount            NUMERIC(18,2)   NOT NULL DEFAULT 0,
    bonus_count_30d             SMALLINT        NOT NULL DEFAULT 0,
    bonus_to_deposit_ratio      NUMERIC(5,4)    NOT NULL DEFAULT 0,
    avg_wagering_completion     NUMERIC(5,4)    NOT NULL DEFAULT 0,
    avg_deposit_to_withdraw_min INT             NOT NULL DEFAULT 0,
    bonus_forfeit_ratio         NUMERIC(5,4)    NOT NULL DEFAULT 0,

    -- Chargeback / Rollback / Reversal
    chargeback_count            SMALLINT        NOT NULL DEFAULT 0,
    last_chargeback_days_ago    SMALLINT        NULL,
    rollback_count_30d          SMALLINT        NOT NULL DEFAULT 0,
    withdrawal_reversal_count   SMALLINT        NOT NULL DEFAULT 0,
    manual_transaction_ratio    NUMERIC(5,4)    NOT NULL DEFAULT 0,

    -- Para birimi bilgisi
    base_currency               VARCHAR(3)      NOT NULL DEFAULT '',
    primary_currency            VARCHAR(3)      NULL,
    currency_count              SMALLINT        NOT NULL DEFAULT 1,

    updated_at              TIMESTAMPTZ     NOT NULL,

    PRIMARY KEY (tenant_id, player_id)
);

COMMENT ON TABLE risk.risk_player_baselines IS 'Per-player statistical baseline summary for risk analysis. Written by Report Cluster, read by RiskManager. All amounts normalized to tenant base currency.';
