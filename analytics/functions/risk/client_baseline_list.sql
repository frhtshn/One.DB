-- ================================================================
-- CLIENT_BASELINE_LIST: Client baseline listesi
-- ================================================================
-- Tüm client baseline'larını döner. RiskManager başlangıçta ve
-- 5 dk'da bir çağırarak in-memory cache'i yeniler.
-- ================================================================

DROP FUNCTION IF EXISTS risk.client_baseline_list();

CREATE OR REPLACE FUNCTION risk.client_baseline_list()
RETURNS TABLE (
    client_id            INT,
    base_currency        VARCHAR(3),
    avg_deposit          NUMERIC(18,2),
    deposit_stddev       NUMERIC(18,2),
    avg_withdrawal       NUMERIC(18,2),
    withdrawal_stddev    NUMERIC(18,2),
    total_players        INT,
    avg_deposits_per_day NUMERIC(10,4),
    updated_at           TIMESTAMPTZ
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT
        rtb.client_id, rtb.base_currency,
        rtb.avg_deposit, rtb.deposit_stddev,
        rtb.avg_withdrawal, rtb.withdrawal_stddev,
        rtb.total_players, rtb.avg_deposits_per_day,
        rtb.updated_at
    FROM risk.risk_client_baselines rtb;
END;
$$;

COMMENT ON FUNCTION risk.client_baseline_list() IS
'Returns all client baselines for in-memory cache refresh. Called by RiskManager at startup and every 5 minutes.
Access: RiskManager (EXECUTE).
Returns: Full table scan of risk_client_baselines.';
