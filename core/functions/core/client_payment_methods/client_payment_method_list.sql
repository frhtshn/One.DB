-- ================================================================
-- CLIENT_PAYMENT_METHOD_LIST: Client ödeme metot listesi (BO admin)
-- ================================================================
-- Denormalize alanlardan sorgu, catalog JOIN YOK (cross-DB).
-- Provider filtresi + payment_type filtresi + metin arama + sayfalama.
-- ================================================================

DROP FUNCTION IF EXISTS core.client_payment_method_list(BIGINT, BIGINT, VARCHAR, VARCHAR, BOOLEAN, TEXT, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION core.client_payment_method_list(
    p_caller_id BIGINT,
    p_client_id BIGINT,
    p_provider_code VARCHAR(50) DEFAULT NULL,
    p_payment_type VARCHAR(50) DEFAULT NULL,
    p_is_enabled BOOLEAN DEFAULT NULL,
    p_search TEXT DEFAULT NULL,
    p_limit INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
    v_company_id BIGINT;
    v_total INTEGER;
    v_items JSONB;
BEGIN
    -- Client varlık kontrolü
    SELECT company_id INTO v_company_id
    FROM core.clients WHERE id = p_client_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.client.not-found';
    END IF;

    -- IDOR kontrolü
    PERFORM security.user_assert_access_company(p_caller_id, v_company_id);

    -- Toplam sayı
    SELECT COUNT(*) INTO v_total
    FROM core.client_payment_methods tpm
    WHERE tpm.client_id = p_client_id
      AND (p_provider_code IS NULL OR tpm.provider_code = UPPER(TRIM(p_provider_code)))
      AND (p_payment_type IS NULL OR tpm.payment_type = UPPER(TRIM(p_payment_type)))
      AND (p_is_enabled IS NULL OR tpm.is_enabled = p_is_enabled)
      AND (p_search IS NULL OR
           tpm.payment_method_name ILIKE '%' || p_search || '%' OR
           tpm.payment_method_code ILIKE '%' || p_search || '%' OR
           tpm.custom_name ILIKE '%' || p_search || '%');

    -- Metot listesi
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', tpm.id,
            'paymentMethodId', tpm.payment_method_id,
            'paymentMethodName', tpm.payment_method_name,
            'paymentMethodCode', tpm.payment_method_code,
            'providerCode', tpm.provider_code,
            'paymentType', tpm.payment_type,
            'iconUrl', tpm.icon_url,
            'isEnabled', tpm.is_enabled,
            'isVisible', tpm.is_visible,
            'isFeatured', tpm.is_featured,
            'displayOrder', tpm.display_order,
            'customName', tpm.custom_name,
            'customIconUrl', tpm.custom_icon_url,
            'customDescription', tpm.custom_description,
            'allowDeposit', tpm.allow_deposit,
            'allowWithdrawal', tpm.allow_withdrawal,
            'overrideMinDeposit', tpm.override_min_deposit,
            'overrideMaxDeposit', tpm.override_max_deposit,
            'overrideMinWithdrawal', tpm.override_min_withdrawal,
            'overrideMaxWithdrawal', tpm.override_max_withdrawal,
            'overrideDailyDepositLimit', tpm.override_daily_deposit_limit,
            'overrideDailyWithdrawalLimit', tpm.override_daily_withdrawal_limit,
            'overrideDepositFeePercent', tpm.override_deposit_fee_percent,
            'overrideDepositFeeFixed', tpm.override_deposit_fee_fixed,
            'overrideWithdrawalFeePercent', tpm.override_withdrawal_fee_percent,
            'overrideWithdrawalFeeFixed', tpm.override_withdrawal_fee_fixed,
            'overrideKycLevel', tpm.override_kyc_level,
            'allowedPlatforms', tpm.allowed_platforms,
            'blockedCountries', tpm.blocked_countries,
            'allowedCountries', tpm.allowed_countries,
            'availableFrom', tpm.available_from,
            'availableUntil', tpm.available_until,
            'syncStatus', tpm.sync_status,
            'lastSyncedAt', tpm.last_synced_at,
            'createdAt', tpm.created_at,
            'updatedAt', tpm.updated_at
        ) ORDER BY tpm.display_order ASC, tpm.id ASC
    ), '[]'::jsonb)
    INTO v_items
    FROM core.client_payment_methods tpm
    WHERE tpm.client_id = p_client_id
      AND (p_provider_code IS NULL OR tpm.provider_code = UPPER(TRIM(p_provider_code)))
      AND (p_payment_type IS NULL OR tpm.payment_type = UPPER(TRIM(p_payment_type)))
      AND (p_is_enabled IS NULL OR tpm.is_enabled = p_is_enabled)
      AND (p_search IS NULL OR
           tpm.payment_method_name ILIKE '%' || p_search || '%' OR
           tpm.payment_method_code ILIKE '%' || p_search || '%' OR
           tpm.custom_name ILIKE '%' || p_search || '%')
    ORDER BY tpm.display_order ASC, tpm.id ASC
    LIMIT p_limit OFFSET p_offset;

    RETURN jsonb_build_object(
        'items', v_items,
        'totalCount', v_total,
        'limit', p_limit,
        'offset', p_offset
    );
END;
$$;

COMMENT ON FUNCTION core.client_payment_method_list IS 'Returns client payment method list for BO admin. Uses denormalized fields (no cross-DB JOIN). Supports provider, type, status filtering and text search. IDOR protected.';
