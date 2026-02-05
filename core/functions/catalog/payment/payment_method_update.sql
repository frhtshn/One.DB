-- ================================================================
-- PAYMENT_METHOD_UPDATE: Ödeme yöntemi günceller
-- NULL geçilen alanlar güncellenmez (COALESCE pattern)
-- ================================================================

DROP FUNCTION IF EXISTS catalog.payment_method_update(
    BIGINT, BIGINT, VARCHAR, VARCHAR, VARCHAR, VARCHAR, TEXT, VARCHAR, VARCHAR,
    VARCHAR, VARCHAR, VARCHAR, BOOLEAN, BOOLEAN, BOOLEAN,
    DECIMAL, DECIMAL, DECIMAL, DECIMAL,
    DECIMAL, DECIMAL, DECIMAL, DECIMAL,
    VARCHAR, VARCHAR, CHAR(3)[], CHAR(2)[], SMALLINT, BOOLEAN, BOOLEAN,
    VARCHAR[], BOOLEAN, BOOLEAN, BOOLEAN, BOOLEAN, BOOLEAN, BOOLEAN, INTEGER, BOOLEAN
);

CREATE OR REPLACE FUNCTION catalog.payment_method_update(
    p_id BIGINT,
    p_provider_id BIGINT DEFAULT NULL,
    p_code VARCHAR(100) DEFAULT NULL,
    p_name VARCHAR(255) DEFAULT NULL,
    p_payment_type VARCHAR(50) DEFAULT NULL,
    p_external_method_id VARCHAR(100) DEFAULT NULL,
    p_description TEXT DEFAULT NULL,
    p_payment_subtype VARCHAR(50) DEFAULT NULL,
    p_channel VARCHAR(50) DEFAULT NULL,
    p_icon_url VARCHAR(500) DEFAULT NULL,
    p_logo_url VARCHAR(500) DEFAULT NULL,
    p_banner_url VARCHAR(500) DEFAULT NULL,
    p_supports_deposit BOOLEAN DEFAULT NULL,
    p_supports_withdrawal BOOLEAN DEFAULT NULL,
    p_supports_refund BOOLEAN DEFAULT NULL,
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
    p_supported_currencies CHAR(3)[] DEFAULT NULL,
    p_blocked_countries CHAR(2)[] DEFAULT NULL,
    p_requires_kyc_level SMALLINT DEFAULT NULL,
    p_requires_3ds BOOLEAN DEFAULT NULL,
    p_requires_verification BOOLEAN DEFAULT NULL,
    p_features VARCHAR(50)[] DEFAULT NULL,
    p_supports_recurring BOOLEAN DEFAULT NULL,
    p_supports_tokenization BOOLEAN DEFAULT NULL,
    p_supports_partial_refund BOOLEAN DEFAULT NULL,
    p_is_mobile BOOLEAN DEFAULT NULL,
    p_is_desktop BOOLEAN DEFAULT NULL,
    p_is_app BOOLEAN DEFAULT NULL,
    p_sort_order INTEGER DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_code VARCHAR(100);
    v_existing_id BIGINT;
BEGIN
    -- ID kontrolü
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.payment-method.id-required';
    END IF;

    -- Mevcut kayıt kontrolü
    IF NOT EXISTS(SELECT 1 FROM catalog.payment_methods pm WHERE pm.id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.payment-method.not-found';
    END IF;

    -- Provider değiştiriliyorsa varlık kontrolü
    IF p_provider_id IS NOT NULL THEN
        IF NOT EXISTS(SELECT 1 FROM catalog.providers p WHERE p.id = p_provider_id) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.provider.not-found';
        END IF;
    END IF;

    -- Kod değiştiriliyorsa
    IF p_code IS NOT NULL THEN
        IF LENGTH(TRIM(p_code)) < 2 THEN
            RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.payment-method.code-invalid';
        END IF;

        v_code := LOWER(TRIM(p_code));

        -- Unique kontrolü (aynı provider içinde)
        SELECT pm.id INTO v_existing_id
        FROM catalog.payment_methods pm
        WHERE pm.payment_method_code = v_code
          AND pm.provider_id = COALESCE(p_provider_id, (SELECT provider_id FROM catalog.payment_methods WHERE id = p_id))
          AND pm.id != p_id;

        IF v_existing_id IS NOT NULL THEN
            RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.payment-method.code-exists';
        END IF;
    END IF;

    -- Payment type kontrolü
    IF p_payment_type IS NOT NULL AND p_payment_type NOT IN ('CARD', 'EWALLET', 'BANK', 'CRYPTO', 'MOBILE', 'VOUCHER') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.payment-method.type-invalid';
    END IF;

    -- Güncelle (NULL olanlar mevcut değeri korur)
    UPDATE catalog.payment_methods pm
    SET provider_id = COALESCE(p_provider_id, pm.provider_id),
        payment_method_code = COALESCE(LOWER(TRIM(p_code)), pm.payment_method_code),
        payment_method_name = COALESCE(TRIM(p_name), pm.payment_method_name),
        payment_type = COALESCE(UPPER(p_payment_type), pm.payment_type),
        external_method_id = COALESCE(p_external_method_id, pm.external_method_id),
        description = COALESCE(p_description, pm.description),
        payment_subtype = COALESCE(UPPER(p_payment_subtype), pm.payment_subtype),
        channel = COALESCE(UPPER(p_channel), pm.channel),
        icon_url = COALESCE(p_icon_url, pm.icon_url),
        logo_url = COALESCE(p_logo_url, pm.logo_url),
        banner_url = COALESCE(p_banner_url, pm.banner_url),
        supports_deposit = COALESCE(p_supports_deposit, pm.supports_deposit),
        supports_withdrawal = COALESCE(p_supports_withdrawal, pm.supports_withdrawal),
        supports_refund = COALESCE(p_supports_refund, pm.supports_refund),
        min_deposit = COALESCE(p_min_deposit, pm.min_deposit),
        max_deposit = COALESCE(p_max_deposit, pm.max_deposit),
        min_withdrawal = COALESCE(p_min_withdrawal, pm.min_withdrawal),
        max_withdrawal = COALESCE(p_max_withdrawal, pm.max_withdrawal),
        deposit_fee_percent = COALESCE(p_deposit_fee_percent, pm.deposit_fee_percent),
        deposit_fee_fixed = COALESCE(p_deposit_fee_fixed, pm.deposit_fee_fixed),
        withdrawal_fee_percent = COALESCE(p_withdrawal_fee_percent, pm.withdrawal_fee_percent),
        withdrawal_fee_fixed = COALESCE(p_withdrawal_fee_fixed, pm.withdrawal_fee_fixed),
        deposit_processing_time = COALESCE(p_deposit_processing_time, pm.deposit_processing_time),
        withdrawal_processing_time = COALESCE(p_withdrawal_processing_time, pm.withdrawal_processing_time),
        supported_currencies = COALESCE(p_supported_currencies, pm.supported_currencies),
        blocked_countries = COALESCE(p_blocked_countries, pm.blocked_countries),
        requires_kyc_level = COALESCE(p_requires_kyc_level, pm.requires_kyc_level),
        requires_3ds = COALESCE(p_requires_3ds, pm.requires_3ds),
        requires_verification = COALESCE(p_requires_verification, pm.requires_verification),
        features = COALESCE(p_features, pm.features),
        supports_recurring = COALESCE(p_supports_recurring, pm.supports_recurring),
        supports_tokenization = COALESCE(p_supports_tokenization, pm.supports_tokenization),
        supports_partial_refund = COALESCE(p_supports_partial_refund, pm.supports_partial_refund),
        is_mobile = COALESCE(p_is_mobile, pm.is_mobile),
        is_desktop = COALESCE(p_is_desktop, pm.is_desktop),
        is_app = COALESCE(p_is_app, pm.is_app),
        sort_order = COALESCE(p_sort_order, pm.sort_order),
        is_active = COALESCE(p_is_active, pm.is_active),
        updated_at = NOW()
    WHERE pm.id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.payment_method_update IS 'Updates a payment method. NULL values preserve existing data.';
