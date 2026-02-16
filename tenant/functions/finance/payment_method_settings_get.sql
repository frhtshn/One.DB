-- ================================================================
-- PAYMENT_METHOD_SETTINGS_GET: Tekil ödeme metot detay (cashier flow)
-- ================================================================
-- Player ödeme yaparken backend bu fonksiyonu çağırır.
-- Auth-agnostic (cross-DB auth pattern).
-- ================================================================

DROP FUNCTION IF EXISTS finance.payment_method_settings_get(BIGINT);

CREATE OR REPLACE FUNCTION finance.payment_method_settings_get(
    p_payment_method_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
BEGIN
    IF p_payment_method_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.payment-method.id-required';
    END IF;

    SELECT jsonb_build_object(
        'paymentMethodId', pms.payment_method_id,
        'providerId', pms.provider_id,
        'providerCode', pms.provider_code,
        'externalMethodId', pms.external_method_id,
        'paymentMethodCode', pms.payment_method_code,
        'paymentMethodName', pms.payment_method_name,
        'paymentType', pms.payment_type,
        'paymentSubtype', pms.payment_subtype,
        'channel', pms.channel,
        'iconUrl', pms.icon_url,
        'logoUrl', pms.logo_url,
        'allowDeposit', pms.allow_deposit,
        'allowWithdrawal', pms.allow_withdrawal,
        'supportsRefund', pms.supports_refund,
        'features', pms.features,
        'supportsRecurring', pms.supports_recurring,
        'supportsTokenization', pms.supports_tokenization,
        'requiresKycLevel', pms.requires_kyc_level,
        'requires3ds', pms.requires_3ds,
        'requiresVerification', pms.requires_verification,
        'isMobile', pms.is_mobile,
        'isDesktop', pms.is_desktop,
        'isVisible', pms.is_visible,
        'isEnabled', pms.is_enabled,
        'isFeatured', pms.is_featured,
        'displayOrder', pms.display_order,
        'customName', pms.custom_name,
        'customIconUrl', pms.custom_icon_url,
        'customDescription', pms.custom_description,
        'allowedPlatforms', pms.allowed_platforms,
        'blockedCountries', pms.blocked_countries,
        'allowedCountries', pms.allowed_countries,
        'rolloutStatus', pms.rollout_status,
        'availableFrom', pms.available_from,
        'availableUntil', pms.available_until,
        'depositProcessingTime', pms.deposit_processing_time,
        'withdrawalProcessingTime', pms.withdrawal_processing_time,
        'popularityScore', pms.popularity_score,
        'usageCount', pms.usage_count,
        'coreSyncedAt', pms.core_synced_at
    )
    INTO v_result
    FROM finance.payment_method_settings pms
    WHERE pms.payment_method_id = p_payment_method_id;

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.payment-method.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION finance.payment_method_settings_get(BIGINT) IS 'Returns single payment method detail for cashier flow. Backend uses provider_id + external_method_id for Gateway request. Auth-agnostic.';
