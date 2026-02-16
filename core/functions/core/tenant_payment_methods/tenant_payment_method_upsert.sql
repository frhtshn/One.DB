-- ================================================================
-- TENANT_PAYMENT_METHOD_UPSERT: Tekil ödeme metodu aç/düzenle
-- ================================================================
-- BO admin tarafından tenant ödeme metot ayarlarını düzenlemek için.
-- Finance DB validasyonu YAPILMAZ (cross-DB, backend doğrular).
-- Güncelleme sonrası sync_status = 'pending' olur.
-- Limit/fee override, görünürlük, platform ayarları desteklenir.
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_payment_method_upsert(
    BIGINT, BIGINT, BIGINT,
    BOOLEAN, BOOLEAN, BOOLEAN, INTEGER,
    VARCHAR, VARCHAR, TEXT,
    BOOLEAN, BOOLEAN,
    DECIMAL, DECIMAL, DECIMAL, DECIMAL, DECIMAL, DECIMAL,
    DECIMAL, DECIMAL, DECIMAL, DECIMAL,
    SMALLINT,
    VARCHAR(20)[], CHAR(2)[], CHAR(2)[],
    TIMESTAMP, TIMESTAMP
);

CREATE OR REPLACE FUNCTION core.tenant_payment_method_upsert(
    p_caller_id BIGINT,
    p_tenant_id BIGINT,
    p_payment_method_id BIGINT,
    p_is_enabled BOOLEAN DEFAULT NULL,
    p_is_visible BOOLEAN DEFAULT NULL,
    p_is_featured BOOLEAN DEFAULT NULL,
    p_display_order INTEGER DEFAULT NULL,
    p_custom_name VARCHAR(255) DEFAULT NULL,
    p_custom_icon_url VARCHAR(500) DEFAULT NULL,
    p_custom_description TEXT DEFAULT NULL,
    p_allow_deposit BOOLEAN DEFAULT NULL,
    p_allow_withdrawal BOOLEAN DEFAULT NULL,
    p_override_min_deposit DECIMAL(18,8) DEFAULT NULL,
    p_override_max_deposit DECIMAL(18,8) DEFAULT NULL,
    p_override_min_withdrawal DECIMAL(18,8) DEFAULT NULL,
    p_override_max_withdrawal DECIMAL(18,8) DEFAULT NULL,
    p_override_daily_deposit_limit DECIMAL(18,8) DEFAULT NULL,
    p_override_daily_withdrawal_limit DECIMAL(18,8) DEFAULT NULL,
    p_override_deposit_fee_percent DECIMAL(5,4) DEFAULT NULL,
    p_override_deposit_fee_fixed DECIMAL(18,8) DEFAULT NULL,
    p_override_withdrawal_fee_percent DECIMAL(5,4) DEFAULT NULL,
    p_override_withdrawal_fee_fixed DECIMAL(18,8) DEFAULT NULL,
    p_override_kyc_level SMALLINT DEFAULT NULL,
    p_allowed_platforms VARCHAR(20)[] DEFAULT NULL,
    p_blocked_countries CHAR(2)[] DEFAULT NULL,
    p_allowed_countries CHAR(2)[] DEFAULT NULL,
    p_available_from TIMESTAMP DEFAULT NULL,
    p_available_until TIMESTAMP DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_company_id BIGINT;
BEGIN
    -- Tenant varlık kontrolü
    SELECT company_id INTO v_company_id
    FROM core.tenants WHERE id = p_tenant_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    -- IDOR kontrolü
    PERFORM security.user_assert_access_company(p_caller_id, v_company_id);

    -- payment_method_id zorunlu
    IF p_payment_method_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.payment-method.id-required';
    END IF;

    -- tenant_payment_methods kaydı mevcut olmalı (backend seed etmiş olmalı)
    IF NOT EXISTS(
        SELECT 1 FROM core.tenant_payment_methods
        WHERE tenant_id = p_tenant_id AND payment_method_id = p_payment_method_id
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant-payment-method.not-found';
    END IF;

    -- COALESCE güncelleme
    UPDATE core.tenant_payment_methods SET
        is_enabled = COALESCE(p_is_enabled, is_enabled),
        is_visible = COALESCE(p_is_visible, is_visible),
        is_featured = COALESCE(p_is_featured, is_featured),
        display_order = COALESCE(p_display_order, display_order),
        custom_name = COALESCE(p_custom_name, custom_name),
        custom_icon_url = COALESCE(p_custom_icon_url, custom_icon_url),
        custom_description = COALESCE(p_custom_description, custom_description),
        allow_deposit = COALESCE(p_allow_deposit, allow_deposit),
        allow_withdrawal = COALESCE(p_allow_withdrawal, allow_withdrawal),
        override_min_deposit = COALESCE(p_override_min_deposit, override_min_deposit),
        override_max_deposit = COALESCE(p_override_max_deposit, override_max_deposit),
        override_min_withdrawal = COALESCE(p_override_min_withdrawal, override_min_withdrawal),
        override_max_withdrawal = COALESCE(p_override_max_withdrawal, override_max_withdrawal),
        override_daily_deposit_limit = COALESCE(p_override_daily_deposit_limit, override_daily_deposit_limit),
        override_daily_withdrawal_limit = COALESCE(p_override_daily_withdrawal_limit, override_daily_withdrawal_limit),
        override_deposit_fee_percent = COALESCE(p_override_deposit_fee_percent, override_deposit_fee_percent),
        override_deposit_fee_fixed = COALESCE(p_override_deposit_fee_fixed, override_deposit_fee_fixed),
        override_withdrawal_fee_percent = COALESCE(p_override_withdrawal_fee_percent, override_withdrawal_fee_percent),
        override_withdrawal_fee_fixed = COALESCE(p_override_withdrawal_fee_fixed, override_withdrawal_fee_fixed),
        override_kyc_level = COALESCE(p_override_kyc_level, override_kyc_level),
        allowed_platforms = COALESCE(p_allowed_platforms, allowed_platforms),
        blocked_countries = COALESCE(p_blocked_countries, blocked_countries),
        allowed_countries = COALESCE(p_allowed_countries, allowed_countries),
        available_from = COALESCE(p_available_from, available_from),
        available_until = COALESCE(p_available_until, available_until),
        sync_status = 'pending',
        updated_at = NOW(),
        updated_by = p_caller_id
    WHERE tenant_id = p_tenant_id AND payment_method_id = p_payment_method_id;
END;
$$;

COMMENT ON FUNCTION core.tenant_payment_method_upsert IS 'Updates tenant payment method customization (limits, fees, visibility, platforms, etc). COALESCE pattern. Sets sync_status=pending. IDOR protected.';
