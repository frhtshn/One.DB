-- ================================================================
-- PAYMENT_METHOD_LOOKUP: Payment method dropdown için basit liste
-- SuperAdmin erişebilir (payment_method_list ile tutarlı)
-- Opsiyonel provider_id filtresi
-- ================================================================

DROP FUNCTION IF EXISTS catalog.payment_method_lookup(BIGINT);
DROP FUNCTION IF EXISTS catalog.payment_method_lookup(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION catalog.payment_method_lookup(
    p_caller_id BIGINT,
    p_provider_id BIGINT DEFAULT NULL
)
RETURNS TABLE(
    id BIGINT,
    code VARCHAR(100),
    name VARCHAR(255),
    provider_id BIGINT,
    provider_code VARCHAR(50),
    provider_name VARCHAR(255),
    payment_type VARCHAR(50),
    supports_deposit BOOLEAN,
    supports_withdrawal BOOLEAN,
    is_active BOOLEAN
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
BEGIN
    -- SuperAdmin check
    PERFORM security.user_assert_superadmin(p_caller_id);

    RETURN QUERY
    SELECT
        pm.id,
        pm.payment_method_code AS code,
        pm.payment_method_name AS name,
        pm.provider_id,
        p.provider_code,
        p.provider_name,
        pm.payment_type,
        pm.supports_deposit,
        pm.supports_withdrawal,
        pm.is_active
    FROM catalog.payment_methods pm
    JOIN catalog.providers p ON p.id = pm.provider_id
    WHERE (p_provider_id IS NULL OR pm.provider_id = p_provider_id)
    ORDER BY pm.sort_order, pm.payment_method_name;
END;
$$;

COMMENT ON FUNCTION catalog.payment_method_lookup(BIGINT, BIGINT) IS 'Returns payment method list for dropdowns. Optional provider_id filter. SuperAdmin only.';
