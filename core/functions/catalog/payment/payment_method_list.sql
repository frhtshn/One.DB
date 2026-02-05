-- ================================================================
-- PAYMENT_METHOD_LIST: Ödeme yöntemlerini listeler
-- Opsiyonel provider_id, payment_type ve is_active filtresi
-- ================================================================

DROP FUNCTION IF EXISTS catalog.payment_method_list(BIGINT, VARCHAR, BOOLEAN);

CREATE OR REPLACE FUNCTION catalog.payment_method_list(
    p_provider_id BIGINT DEFAULT NULL,
    p_payment_type VARCHAR(50) DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL
)
RETURNS TABLE(
    id BIGINT,
    provider_id BIGINT,
    provider_code VARCHAR(50),
    provider_name VARCHAR(255),
    external_method_id VARCHAR(100),
    payment_method_code VARCHAR(100),
    payment_method_name VARCHAR(255),
    description TEXT,
    payment_type VARCHAR(50),
    payment_subtype VARCHAR(50),
    channel VARCHAR(50),
    icon_url VARCHAR(500),
    logo_url VARCHAR(500),
    supports_deposit BOOLEAN,
    supports_withdrawal BOOLEAN,
    min_deposit DECIMAL(18,8),
    max_deposit DECIMAL(18,8),
    min_withdrawal DECIMAL(18,8),
    max_withdrawal DECIMAL(18,8),
    deposit_fee_percent DECIMAL(5,4),
    deposit_fee_fixed DECIMAL(18,8),
    withdrawal_fee_percent DECIMAL(5,4),
    withdrawal_fee_fixed DECIMAL(18,8),
    requires_kyc_level SMALLINT,
    sort_order INTEGER,
    is_active BOOLEAN,
    created_at TIMESTAMP
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT
        pm.id,
        pm.provider_id,
        p.provider_code,
        p.provider_name,
        pm.external_method_id,
        pm.payment_method_code,
        pm.payment_method_name,
        pm.description,
        pm.payment_type,
        pm.payment_subtype,
        pm.channel,
        pm.icon_url,
        pm.logo_url,
        pm.supports_deposit,
        pm.supports_withdrawal,
        pm.min_deposit,
        pm.max_deposit,
        pm.min_withdrawal,
        pm.max_withdrawal,
        pm.deposit_fee_percent,
        pm.deposit_fee_fixed,
        pm.withdrawal_fee_percent,
        pm.withdrawal_fee_fixed,
        pm.requires_kyc_level,
        pm.sort_order,
        pm.is_active,
        pm.created_at
    FROM catalog.payment_methods pm
    JOIN catalog.providers p ON p.id = pm.provider_id
    WHERE (p_provider_id IS NULL OR pm.provider_id = p_provider_id)
      AND (p_payment_type IS NULL OR pm.payment_type = UPPER(p_payment_type))
      AND (p_is_active IS NULL OR pm.is_active = p_is_active)
    ORDER BY pm.sort_order, pm.payment_method_name;
END;
$$;

COMMENT ON FUNCTION catalog.payment_method_list IS 'Lists payment methods with optional filters.';
