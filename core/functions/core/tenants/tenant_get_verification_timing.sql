-- ================================================================
-- TENANT_GET_VERIFICATION_TIMING: Tenant'in primary jurisdiction'ina
-- ait KYC verification timing degerini doner.
-- tenant_jurisdictions (is_primary) -> kyc_policies (verification_timing)
-- Bulunamazsa NULL doner.
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_get_verification_timing(BIGINT);

CREATE OR REPLACE FUNCTION core.tenant_get_verification_timing(
    p_tenant_id BIGINT
)
RETURNS VARCHAR
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    SELECT kp.verification_timing
    FROM core.tenant_jurisdictions tj
    JOIN catalog.kyc_policies kp ON kp.jurisdiction_id = tj.jurisdiction_id
    WHERE tj.tenant_id = p_tenant_id
      AND tj.is_primary = true
      AND tj.status = 'active'
      AND kp.is_active = true
    LIMIT 1;
$$;

COMMENT ON FUNCTION core.tenant_get_verification_timing(BIGINT) IS
'Returns the KYC verification timing for the tenant primary jurisdiction. NULL if not configured.';
