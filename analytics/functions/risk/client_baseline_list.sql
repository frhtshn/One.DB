-- ================================================================
-- TENANT_BASELINE_LIST: Tenant baseline listesi
-- ================================================================
-- Tüm tenant baseline'larını döner. RiskManager başlangıçta ve
-- 5 dk'da bir çağırarak in-memory cache'i yeniler.
-- ================================================================

DROP FUNCTION IF EXISTS risk.tenant_baseline_list();

CREATE OR REPLACE FUNCTION risk.tenant_baseline_list()
RETURNS TABLE (
    tenant_id            INT,
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
        rtb.tenant_id, rtb.base_currency,
        rtb.avg_deposit, rtb.deposit_stddev,
        rtb.avg_withdrawal, rtb.withdrawal_stddev,
        rtb.total_players, rtb.avg_deposits_per_day,
        rtb.updated_at
    FROM risk.risk_tenant_baselines rtb;
END;
$$;

COMMENT ON FUNCTION risk.tenant_baseline_list() IS
'Returns all tenant baselines for in-memory cache refresh. Called by RiskManager at startup and every 5 minutes.
Access: RiskManager (EXECUTE).
Returns: Full table scan of risk_tenant_baselines.';
