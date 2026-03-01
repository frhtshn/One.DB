-- ================================================================
-- PLAYER_BASELINE_LIST: Oyuncu baseline listesi
-- ================================================================
-- Tüm oyuncu baseline'larını döner. RiskManager başlangıçta ve
-- 5 dk'da bir çağırarak in-memory cache'i yeniler.
-- ================================================================

DROP FUNCTION IF EXISTS risk.player_baseline_list();

CREATE OR REPLACE FUNCTION risk.player_baseline_list()
RETURNS TABLE (
    client_id                INT,
    player_id                BIGINT,
    avg_deposit              NUMERIC(18,2),
    deposit_stddev           NUMERIC(18,2),
    avg_withdrawal           NUMERIC(18,2),
    withdrawal_stddev        NUMERIC(18,2),
    avg_deposits_per_day     NUMERIC(10,4),
    avg_withdrawals_per_day  NUMERIC(10,4),
    avg_deposit_interval_sec INT,
    deposit_interval_stddev  INT,
    deposit_count_24h        SMALLINT,
    withdrawal_count_24h     SMALLINT,
    last_deposit_ts          TIMESTAMPTZ,
    last_withdrawal_ts       TIMESTAMPTZ,
    transaction_count        INT,
    avg_bonus_amount         NUMERIC(18,2),
    bonus_count_30d          SMALLINT,
    bonus_to_deposit_ratio   NUMERIC(5,4),
    avg_wagering_completion  NUMERIC(5,4),
    avg_deposit_to_withdraw_min INT,
    bonus_forfeit_ratio      NUMERIC(5,4),
    chargeback_count         SMALLINT,
    last_chargeback_days_ago SMALLINT,
    rollback_count_30d       SMALLINT,
    withdrawal_reversal_count SMALLINT,
    manual_transaction_ratio NUMERIC(5,4),
    base_currency            VARCHAR(3),
    primary_currency         VARCHAR(3),
    currency_count           SMALLINT,
    updated_at               TIMESTAMPTZ
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT
        rpb.client_id, rpb.player_id,
        rpb.avg_deposit, rpb.deposit_stddev,
        rpb.avg_withdrawal, rpb.withdrawal_stddev,
        rpb.avg_deposits_per_day, rpb.avg_withdrawals_per_day,
        rpb.avg_deposit_interval_sec, rpb.deposit_interval_stddev,
        rpb.deposit_count_24h, rpb.withdrawal_count_24h,
        rpb.last_deposit_ts, rpb.last_withdrawal_ts,
        rpb.transaction_count,
        rpb.avg_bonus_amount, rpb.bonus_count_30d,
        rpb.bonus_to_deposit_ratio, rpb.avg_wagering_completion,
        rpb.avg_deposit_to_withdraw_min, rpb.bonus_forfeit_ratio,
        rpb.chargeback_count, rpb.last_chargeback_days_ago,
        rpb.rollback_count_30d, rpb.withdrawal_reversal_count,
        rpb.manual_transaction_ratio,
        rpb.base_currency, rpb.primary_currency, rpb.currency_count,
        rpb.updated_at
    FROM risk.risk_player_baselines rpb;
END;
$$;

COMMENT ON FUNCTION risk.player_baseline_list() IS
'Returns all player baselines for in-memory cache refresh. Called by RiskManager at startup and every 5 minutes.
Access: RiskManager (EXECUTE).
Returns: Full table scan of risk_player_baselines.';
