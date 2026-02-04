-- ================================================================
-- PAYMENT_METHOD_CREATE: Yeni ödeme yöntemi oluşturur
-- Sadece SuperAdmin kullanabilir (IDOR korumalı)
-- Zorunlu: provider_id, code, name, payment_type
-- ================================================================

DROP FUNCTION IF EXISTS catalog.payment_method_create(
    BIGINT, BIGINT, VARCHAR, VARCHAR, VARCHAR, VARCHAR, TEXT, VARCHAR, VARCHAR,
    VARCHAR, VARCHAR, VARCHAR, BOOLEAN, BOOLEAN, BOOLEAN,
    DECIMAL, DECIMAL, DECIMAL, DECIMAL,
    DECIMAL, DECIMAL, DECIMAL, DECIMAL,
    VARCHAR, VARCHAR, CHAR(3)[], CHAR(2)[], SMALLINT, BOOLEAN, BOOLEAN,
    VARCHAR[], BOOLEAN, BOOLEAN, BOOLEAN, BOOLEAN, BOOLEAN, BOOLEAN, INTEGER
);

CREATE OR REPLACE FUNCTION catalog.payment_method_create(
    p_caller_id BIGINT,
    p_provider_id BIGINT,
    p_code VARCHAR(100),
    p_name VARCHAR(255),
    p_payment_type VARCHAR(50),
    -- Opsiyonel parametreler
    p_external_method_id VARCHAR(100) DEFAULT NULL,
    p_description TEXT DEFAULT NULL,
    p_payment_subtype VARCHAR(50) DEFAULT NULL,
    p_channel VARCHAR(50) DEFAULT 'ONLINE',
    p_icon_url VARCHAR(500) DEFAULT NULL,
    p_logo_url VARCHAR(500) DEFAULT NULL,
    p_banner_url VARCHAR(500) DEFAULT NULL,
    p_supports_deposit BOOLEAN DEFAULT TRUE,
    p_supports_withdrawal BOOLEAN DEFAULT TRUE,
    p_supports_refund BOOLEAN DEFAULT FALSE,
    p_min_deposit DECIMAL(18,8) DEFAULT NULL,
    p_max_deposit DECIMAL(18,8) DEFAULT NULL,
    p_min_withdrawal DECIMAL(18,8) DEFAULT NULL,
    p_max_withdrawal DECIMAL(18,8) DEFAULT NULL,
    p_deposit_fee_percent DECIMAL(5,4) DEFAULT NULL,
    p_deposit_fee_fixed DECIMAL(18,8) DEFAULT NULL,
    p_withdrawal_fee_percent DECIMAL(5,4) DEFAULT NULL,
    p_withdrawal_fee_fixed DECIMAL(18,8) DEFAULT NULL,
    p_deposit_processing_time VARCHAR(50) DEFAULT NULL,
    p_withdrawal_processing_time VARCHAR(50) DEFAULT NULL,
    p_supported_currencies CHAR(3)[] DEFAULT '{}',
    p_blocked_countries CHAR(2)[] DEFAULT '{}',
    p_requires_kyc_level SMALLINT DEFAULT 0,
    p_requires_3ds BOOLEAN DEFAULT FALSE,
    p_requires_verification BOOLEAN DEFAULT FALSE,
    p_features VARCHAR(50)[] DEFAULT '{}',
    p_supports_recurring BOOLEAN DEFAULT FALSE,
    p_supports_tokenization BOOLEAN DEFAULT FALSE,
    p_supports_partial_refund BOOLEAN DEFAULT FALSE,
    p_is_mobile BOOLEAN DEFAULT TRUE,
    p_is_desktop BOOLEAN DEFAULT TRUE,
    p_is_app BOOLEAN DEFAULT TRUE,
    p_sort_order INTEGER DEFAULT 0
)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_code VARCHAR(100);
    v_name VARCHAR(255);
    v_payment_type VARCHAR(50);
    v_new_id BIGINT;
BEGIN
    -- SuperAdmin check
    PERFORM security.user_assert_superadmin(p_caller_id);

    -- Provider ID kontrolü
    IF p_provider_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.payment-method.provider-required';
    END IF;

    -- Provider varlık kontrolü
    IF NOT EXISTS(SELECT 1 FROM catalog.providers p WHERE p.id = p_provider_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.provider.not-found';
    END IF;

    -- Kod kontrolü
    IF p_code IS NULL OR LENGTH(TRIM(p_code)) < 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.payment-method.code-invalid';
    END IF;

    -- İsim kontrolü
    IF p_name IS NULL OR LENGTH(TRIM(p_name)) < 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.payment-method.name-invalid';
    END IF;

    -- Payment type kontrolü
    IF p_payment_type IS NULL OR p_payment_type NOT IN ('CARD', 'EWALLET', 'BANK', 'CRYPTO', 'MOBILE', 'VOUCHER') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.payment-method.type-invalid';
    END IF;

    v_code := LOWER(TRIM(p_code));
    v_name := TRIM(p_name);
    v_payment_type := UPPER(TRIM(p_payment_type));

    -- Mevcut kod kontrolü (aynı provider içinde unique)
    IF EXISTS(
        SELECT 1 FROM catalog.payment_methods pm
        WHERE pm.provider_id = p_provider_id AND pm.payment_method_code = v_code
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.payment-method.code-exists';
    END IF;

    -- Ekle
    INSERT INTO catalog.payment_methods (
        provider_id, external_method_id, payment_method_code, payment_method_name, description,
        payment_type, payment_subtype, channel, icon_url, logo_url, banner_url,
        supports_deposit, supports_withdrawal, supports_refund,
        min_deposit, max_deposit, min_withdrawal, max_withdrawal,
        deposit_fee_percent, deposit_fee_fixed, withdrawal_fee_percent, withdrawal_fee_fixed,
        deposit_processing_time, withdrawal_processing_time,
        supported_currencies, blocked_countries,
        requires_kyc_level, requires_3ds, requires_verification,
        features, supports_recurring, supports_tokenization, supports_partial_refund,
        is_mobile, is_desktop, is_app, sort_order,
        is_active, created_at, updated_at
    )
    VALUES (
        p_provider_id, p_external_method_id, v_code, v_name, p_description,
        v_payment_type, UPPER(p_payment_subtype), UPPER(COALESCE(p_channel, 'ONLINE')),
        p_icon_url, p_logo_url, p_banner_url,
        p_supports_deposit, p_supports_withdrawal, p_supports_refund,
        p_min_deposit, p_max_deposit, p_min_withdrawal, p_max_withdrawal,
        p_deposit_fee_percent, p_deposit_fee_fixed, p_withdrawal_fee_percent, p_withdrawal_fee_fixed,
        p_deposit_processing_time, p_withdrawal_processing_time,
        p_supported_currencies, p_blocked_countries,
        p_requires_kyc_level, p_requires_3ds, p_requires_verification,
        p_features, p_supports_recurring, p_supports_tokenization, p_supports_partial_refund,
        p_is_mobile, p_is_desktop, p_is_app, p_sort_order,
        TRUE, NOW(), NOW()
    )
    RETURNING id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION catalog.payment_method_create IS 'Creates a new payment method. SuperAdmin only.';
