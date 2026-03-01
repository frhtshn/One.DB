-- ================================================================
-- PLAYER_BASELINE_UPSERT: Oyuncu baseline yazma/güncelleme
-- ================================================================
-- Report Cluster tarafından çağrılır. Her event sonrası oyuncu
-- istatistik özetini yazar veya günceller. updated_at otomatik
-- NOW() ile set edilir.
-- ================================================================

DROP FUNCTION IF EXISTS risk.player_baseline_upsert(INT, BIGINT, NUMERIC, NUMERIC, NUMERIC, NUMERIC, NUMERIC, NUMERIC, INT, INT, SMALLINT, SMALLINT, TIMESTAMPTZ, TIMESTAMPTZ, INT, NUMERIC, SMALLINT, NUMERIC, NUMERIC, INT, NUMERIC, SMALLINT, SMALLINT, SMALLINT, SMALLINT, NUMERIC, VARCHAR, VARCHAR, SMALLINT);

CREATE OR REPLACE FUNCTION risk.player_baseline_upsert(
    p_client_id                INT,
    p_player_id                BIGINT,
    p_avg_deposit              NUMERIC(18,2),
    p_deposit_stddev           NUMERIC(18,2),
    p_avg_withdrawal           NUMERIC(18,2),
    p_withdrawal_stddev        NUMERIC(18,2),
    p_avg_deposits_per_day     NUMERIC(10,4),
    p_avg_withdrawals_per_day  NUMERIC(10,4),
    p_avg_deposit_interval_sec INT,
    p_deposit_interval_stddev  INT,
    p_deposit_count_24h        SMALLINT,
    p_withdrawal_count_24h     SMALLINT,
    p_last_deposit_ts          TIMESTAMPTZ,
    p_last_withdrawal_ts       TIMESTAMPTZ,
    p_transaction_count        INT,
    p_avg_bonus_amount         NUMERIC(18,2),
    p_bonus_count_30d          SMALLINT,
    p_bonus_to_deposit_ratio   NUMERIC(5,4),
    p_avg_wagering_completion  NUMERIC(5,4),
    p_avg_deposit_to_withdraw_min INT,
    p_bonus_forfeit_ratio      NUMERIC(5,4),
    p_chargeback_count         SMALLINT,
    p_last_chargeback_days_ago SMALLINT,
    p_rollback_count_30d       SMALLINT,
    p_withdrawal_reversal_count SMALLINT,
    p_manual_transaction_ratio NUMERIC(5,4),
    p_base_currency            VARCHAR(3),
    p_primary_currency         VARCHAR(3),
    p_currency_count           SMALLINT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO risk.risk_player_baselines (
        client_id, player_id,
        avg_deposit, deposit_stddev, avg_withdrawal, withdrawal_stddev,
        avg_deposits_per_day, avg_withdrawals_per_day,
        avg_deposit_interval_sec, deposit_interval_stddev,
        deposit_count_24h, withdrawal_count_24h,
        last_deposit_ts, last_withdrawal_ts, transaction_count,
        avg_bonus_amount, bonus_count_30d, bonus_to_deposit_ratio,
        avg_wagering_completion, avg_deposit_to_withdraw_min, bonus_forfeit_ratio,
        chargeback_count, last_chargeback_days_ago,
        rollback_count_30d, withdrawal_reversal_count, manual_transaction_ratio,
        base_currency, primary_currency, currency_count,
        updated_at
    ) VALUES (
        p_client_id, p_player_id,
        p_avg_deposit, p_deposit_stddev, p_avg_withdrawal, p_withdrawal_stddev,
        p_avg_deposits_per_day, p_avg_withdrawals_per_day,
        p_avg_deposit_interval_sec, p_deposit_interval_stddev,
        p_deposit_count_24h, p_withdrawal_count_24h,
        p_last_deposit_ts, p_last_withdrawal_ts, p_transaction_count,
        p_avg_bonus_amount, p_bonus_count_30d, p_bonus_to_deposit_ratio,
        p_avg_wagering_completion, p_avg_deposit_to_withdraw_min, p_bonus_forfeit_ratio,
        p_chargeback_count, p_last_chargeback_days_ago,
        p_rollback_count_30d, p_withdrawal_reversal_count, p_manual_transaction_ratio,
        p_base_currency, p_primary_currency, p_currency_count,
        NOW()
    )
    ON CONFLICT (client_id, player_id) DO UPDATE SET
        avg_deposit              = EXCLUDED.avg_deposit,
        deposit_stddev           = EXCLUDED.deposit_stddev,
        avg_withdrawal           = EXCLUDED.avg_withdrawal,
        withdrawal_stddev        = EXCLUDED.withdrawal_stddev,
        avg_deposits_per_day     = EXCLUDED.avg_deposits_per_day,
        avg_withdrawals_per_day  = EXCLUDED.avg_withdrawals_per_day,
        avg_deposit_interval_sec = EXCLUDED.avg_deposit_interval_sec,
        deposit_interval_stddev  = EXCLUDED.deposit_interval_stddev,
        deposit_count_24h        = EXCLUDED.deposit_count_24h,
        withdrawal_count_24h     = EXCLUDED.withdrawal_count_24h,
        last_deposit_ts          = EXCLUDED.last_deposit_ts,
        last_withdrawal_ts       = EXCLUDED.last_withdrawal_ts,
        transaction_count        = EXCLUDED.transaction_count,
        avg_bonus_amount         = EXCLUDED.avg_bonus_amount,
        bonus_count_30d          = EXCLUDED.bonus_count_30d,
        bonus_to_deposit_ratio   = EXCLUDED.bonus_to_deposit_ratio,
        avg_wagering_completion  = EXCLUDED.avg_wagering_completion,
        avg_deposit_to_withdraw_min = EXCLUDED.avg_deposit_to_withdraw_min,
        bonus_forfeit_ratio      = EXCLUDED.bonus_forfeit_ratio,
        chargeback_count         = EXCLUDED.chargeback_count,
        last_chargeback_days_ago = EXCLUDED.last_chargeback_days_ago,
        rollback_count_30d       = EXCLUDED.rollback_count_30d,
        withdrawal_reversal_count = EXCLUDED.withdrawal_reversal_count,
        manual_transaction_ratio = EXCLUDED.manual_transaction_ratio,
        base_currency            = EXCLUDED.base_currency,
        primary_currency         = EXCLUDED.primary_currency,
        currency_count           = EXCLUDED.currency_count,
        updated_at               = NOW();
END;
$$;

COMMENT ON FUNCTION risk.player_baseline_upsert(INT, BIGINT, NUMERIC, NUMERIC, NUMERIC, NUMERIC, NUMERIC, NUMERIC, INT, INT, SMALLINT, SMALLINT, TIMESTAMPTZ, TIMESTAMPTZ, INT, NUMERIC, SMALLINT, NUMERIC, NUMERIC, INT, NUMERIC, SMALLINT, SMALLINT, SMALLINT, SMALLINT, NUMERIC, VARCHAR, VARCHAR, SMALLINT) IS
'Upserts a player statistical baseline. Called by Report Cluster after transaction/bonus events. Sets updated_at to NOW() automatically.
Access: Report Cluster (EXECUTE).
Returns: void.';
