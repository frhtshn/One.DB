-- ================================================================
-- PAYMENT_METHOD_GET: Tekil ödeme yöntemi getirir
-- Sadece SuperAdmin erişebilir
-- Tüm detayları içerir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.payment_method_get(BIGINT);
DROP FUNCTION IF EXISTS catalog.payment_method_get(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION catalog.payment_method_get(
    p_caller_id BIGINT,
    p_id BIGINT
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
    banner_url VARCHAR(500),
    supports_deposit BOOLEAN,
    supports_withdrawal BOOLEAN,
    supports_refund BOOLEAN,
    min_deposit DECIMAL(18,8),
    max_deposit DECIMAL(18,8),
    min_withdrawal DECIMAL(18,8),
    max_withdrawal DECIMAL(18,8),
    deposit_fee_percent DECIMAL(5,4),
    deposit_fee_fixed DECIMAL(18,8),
    withdrawal_fee_percent DECIMAL(5,4),
    withdrawal_fee_fixed DECIMAL(18,8),
    deposit_processing_time VARCHAR(50),
    withdrawal_processing_time VARCHAR(50),
    supported_currencies CHAR(3)[],
    blocked_countries CHAR(2)[],
    requires_kyc_level SMALLINT,
    requires_3ds BOOLEAN,
    requires_verification BOOLEAN,
    features VARCHAR(50)[],
    supports_recurring BOOLEAN,
    supports_tokenization BOOLEAN,
    supports_partial_refund BOOLEAN,
    is_mobile BOOLEAN,
    is_desktop BOOLEAN,
    is_app BOOLEAN,
    sort_order INTEGER,
    popularity_score INTEGER,
    is_active BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
BEGIN
    -- SuperAdmin check
    PERFORM security.user_assert_superadmin(p_caller_id);

    -- ID kontrolü
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.payment-method.id-required';
    END IF;

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
        pm.banner_url,
        pm.supports_deposit,
        pm.supports_withdrawal,
        pm.supports_refund,
        pm.min_deposit,
        pm.max_deposit,
        pm.min_withdrawal,
        pm.max_withdrawal,
        pm.deposit_fee_percent,
        pm.deposit_fee_fixed,
        pm.withdrawal_fee_percent,
        pm.withdrawal_fee_fixed,
        pm.deposit_processing_time,
        pm.withdrawal_processing_time,
        pm.supported_currencies,
        pm.blocked_countries,
        pm.requires_kyc_level,
        pm.requires_3ds,
        pm.requires_verification,
        pm.features,
        pm.supports_recurring,
        pm.supports_tokenization,
        pm.supports_partial_refund,
        pm.is_mobile,
        pm.is_desktop,
        pm.is_app,
        pm.sort_order,
        pm.popularity_score,
        pm.is_active,
        pm.created_at,
        pm.updated_at
    FROM catalog.payment_methods pm
    JOIN catalog.providers p ON p.id = pm.provider_id
    WHERE pm.id = p_id;

    -- Bulunamadı kontrolü
    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.payment-method.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION catalog.payment_method_get IS 'Gets a single payment method with all details. SuperAdmin only.';
