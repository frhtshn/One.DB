-- ================================================================
-- CLIENT_GET_VERIFICATION_TIMING: Client'in primary jurisdiction'ina
-- ait KYC verification timing degerini doner.
-- client_jurisdictions (is_primary) -> kyc_policies (verification_timing)
-- Bulunamazsa NULL doner.
-- ================================================================

DROP FUNCTION IF EXISTS core.client_get_verification_timing(BIGINT);

CREATE OR REPLACE FUNCTION core.client_get_verification_timing(
    p_client_id BIGINT
)
RETURNS VARCHAR
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    SELECT kp.verification_timing
    FROM core.client_jurisdictions tj
    JOIN catalog.kyc_policies kp ON kp.jurisdiction_id = tj.jurisdiction_id
    WHERE tj.client_id = p_client_id
      AND tj.is_primary = true
      AND tj.status = 'active'
      AND kp.is_active = true
    LIMIT 1;
$$;

COMMENT ON FUNCTION core.client_get_verification_timing(BIGINT) IS
'Returns the KYC verification timing for the client primary jurisdiction. NULL if not configured.';
