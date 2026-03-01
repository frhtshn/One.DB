-- ================================================================
-- CLIENT_BASELINE_UPSERT: Client baseline yazma/güncelleme
-- ================================================================
-- Report Cluster tarafından periyodik olarak çağrılır. Client
-- seviyesi istatistik özetini yazar veya günceller. updated_at
-- otomatik NOW() ile set edilir.
-- ================================================================

DROP FUNCTION IF EXISTS risk.client_baseline_upsert(INT, VARCHAR, NUMERIC, NUMERIC, NUMERIC, NUMERIC, INT, NUMERIC);

CREATE OR REPLACE FUNCTION risk.client_baseline_upsert(
    p_client_id            INT,
    p_base_currency        VARCHAR(3),
    p_avg_deposit          NUMERIC(18,2),
    p_deposit_stddev       NUMERIC(18,2),
    p_avg_withdrawal       NUMERIC(18,2),
    p_withdrawal_stddev    NUMERIC(18,2),
    p_total_players        INT,
    p_avg_deposits_per_day NUMERIC(10,4)
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO risk.risk_client_baselines (
        client_id, base_currency,
        avg_deposit, deposit_stddev, avg_withdrawal, withdrawal_stddev,
        total_players, avg_deposits_per_day,
        updated_at
    ) VALUES (
        p_client_id, p_base_currency,
        p_avg_deposit, p_deposit_stddev, p_avg_withdrawal, p_withdrawal_stddev,
        p_total_players, p_avg_deposits_per_day,
        NOW()
    )
    ON CONFLICT (client_id) DO UPDATE SET
        base_currency        = EXCLUDED.base_currency,
        avg_deposit          = EXCLUDED.avg_deposit,
        deposit_stddev       = EXCLUDED.deposit_stddev,
        avg_withdrawal       = EXCLUDED.avg_withdrawal,
        withdrawal_stddev    = EXCLUDED.withdrawal_stddev,
        total_players        = EXCLUDED.total_players,
        avg_deposits_per_day = EXCLUDED.avg_deposits_per_day,
        updated_at           = NOW();
END;
$$;

COMMENT ON FUNCTION risk.client_baseline_upsert(INT, VARCHAR, NUMERIC, NUMERIC, NUMERIC, NUMERIC, INT, NUMERIC) IS
'Upserts a client aggregate baseline. Called periodically by Report Cluster. Sets updated_at to NOW() automatically.
Access: Report Cluster (EXECUTE).
Returns: void.';
