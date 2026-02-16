-- ================================================================
-- PAYMENT_METHOD_LOOKUP: Payment method dropdown için basit liste
-- ================================================================
-- Opsiyonel provider_id filtresi.
-- Core DB'den taşındı — Finance DB catalog'un sahibidir.
-- ================================================================

DROP FUNCTION IF EXISTS catalog.payment_method_lookup(BIGINT);

CREATE OR REPLACE FUNCTION catalog.payment_method_lookup(
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
    RETURN QUERY
    SELECT
        pm.id,
        pm.payment_method_code AS code,
        pm.payment_method_name AS name,
        pm.provider_id,
        pp.provider_code,
        pp.provider_name,
        pm.payment_type,
        pm.supports_deposit,
        pm.supports_withdrawal,
        pm.is_active
    FROM catalog.payment_methods pm
    JOIN catalog.payment_providers pp ON pp.id = pm.provider_id
    WHERE (p_provider_id IS NULL OR pm.provider_id = p_provider_id)
    ORDER BY pm.sort_order, pm.payment_method_name;
END;
$$;

COMMENT ON FUNCTION catalog.payment_method_lookup(BIGINT) IS 'Returns lightweight payment method list for dropdowns from Finance DB catalog. Optional provider_id filter.';
