-- ================================================================
-- PAYMENT_METHOD_SETTINGS_SYNC: Core->Client ödeme metot data upsert
-- ================================================================
-- Backend tarafından çağrılır (auth-agnostic, cross-DB auth pattern).
-- p_catalog_data TEXT → JSONB cast → typed kolonlara extract.
-- INSERT: catalog + client override (default değerler)
-- UPDATE: SADECE catalog alanları — client override'lara DOKUNMAZ
-- ================================================================

DROP FUNCTION IF EXISTS finance.payment_method_settings_sync(BIGINT, TEXT, TEXT, VARCHAR);

CREATE OR REPLACE FUNCTION finance.payment_method_settings_sync(
    p_payment_method_id BIGINT,
    p_catalog_data TEXT,
    p_client_overrides TEXT DEFAULT NULL,
    p_rollout_status VARCHAR(20) DEFAULT 'production'
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_catalog JSONB;
    v_overrides JSONB;
    v_exists BOOLEAN;
BEGIN
    -- Parametre kontrolleri
    IF p_payment_method_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.payment-method.id-required';
    END IF;

    IF p_catalog_data IS NULL OR TRIM(p_catalog_data) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.payment-method.catalog-data-required';
    END IF;

    v_catalog := p_catalog_data::JSONB;
    v_overrides := COALESCE(NULLIF(TRIM(p_client_overrides), ''), '{}')::JSONB;

    -- Mevcut kayıt kontrolü
    SELECT EXISTS(SELECT 1 FROM finance.payment_method_settings WHERE payment_method_id = p_payment_method_id) INTO v_exists;

    IF v_exists THEN
        -- UPDATE: Sadece catalog alanları güncellenir, client override'lara DOKUNULMAZ
        UPDATE finance.payment_method_settings SET
            provider_id = COALESCE((v_catalog->>'provider_id')::BIGINT, provider_id),
            external_method_id = COALESCE(v_catalog->>'external_method_id', external_method_id),
            payment_method_code = COALESCE(v_catalog->>'payment_method_code', payment_method_code),
            payment_method_name = COALESCE(v_catalog->>'payment_method_name', payment_method_name),
            provider_code = COALESCE(v_catalog->>'provider_code', provider_code),
            payment_type = COALESCE(v_catalog->>'payment_type', payment_type),
            payment_subtype = COALESCE(v_catalog->>'payment_subtype', payment_subtype),
            channel = COALESCE(v_catalog->>'channel', channel),
            icon_url = COALESCE(v_catalog->>'icon_url', icon_url),
            logo_url = COALESCE(v_catalog->>'logo_url', logo_url),
            supports_refund = COALESCE((v_catalog->>'supports_refund')::BOOLEAN, supports_refund),
            features = COALESCE(
                (SELECT array_agg(x::VARCHAR(50)) FROM jsonb_array_elements_text(v_catalog->'features') x),
                features
            ),
            supports_recurring = COALESCE((v_catalog->>'supports_recurring')::BOOLEAN, supports_recurring),
            supports_tokenization = COALESCE((v_catalog->>'supports_tokenization')::BOOLEAN, supports_tokenization),
            requires_kyc_level = COALESCE((v_catalog->>'requires_kyc_level')::SMALLINT, requires_kyc_level),
            requires_3ds = COALESCE((v_catalog->>'requires_3ds')::BOOLEAN, requires_3ds),
            requires_verification = COALESCE((v_catalog->>'requires_verification')::BOOLEAN, requires_verification),
            is_mobile = COALESCE((v_catalog->>'is_mobile')::BOOLEAN, is_mobile),
            is_desktop = COALESCE((v_catalog->>'is_desktop')::BOOLEAN, is_desktop),
            deposit_processing_time = COALESCE(v_catalog->>'deposit_processing_time', deposit_processing_time),
            withdrawal_processing_time = COALESCE(v_catalog->>'withdrawal_processing_time', withdrawal_processing_time),
            core_synced_at = NOW(),
            updated_at = NOW()
        WHERE payment_method_id = p_payment_method_id;
    ELSE
        -- INSERT: catalog alanları + client override default değerleri
        INSERT INTO finance.payment_method_settings (
            payment_method_id, provider_id, external_method_id,
            payment_method_code, payment_method_name, provider_code,
            payment_type, payment_subtype, channel,
            icon_url, logo_url,
            allow_deposit, allow_withdrawal, supports_refund,
            features, supports_recurring, supports_tokenization,
            requires_kyc_level, requires_3ds, requires_verification,
            is_mobile, is_desktop,
            display_order, is_visible, is_enabled, is_featured,
            blocked_countries, allowed_countries,
            allowed_platforms,
            deposit_processing_time, withdrawal_processing_time,
            rollout_status,
            core_synced_at, created_at, updated_at
        ) VALUES (
            p_payment_method_id,
            (v_catalog->>'provider_id')::BIGINT,
            v_catalog->>'external_method_id',
            v_catalog->>'payment_method_code',
            v_catalog->>'payment_method_name',
            v_catalog->>'provider_code',
            COALESCE(v_catalog->>'payment_type', 'CARD'),
            v_catalog->>'payment_subtype',
            COALESCE(v_catalog->>'channel', 'ONLINE'),
            v_catalog->>'icon_url',
            v_catalog->>'logo_url',
            COALESCE((v_overrides->>'allow_deposit')::BOOLEAN, true),
            COALESCE((v_overrides->>'allow_withdrawal')::BOOLEAN, true),
            COALESCE((v_catalog->>'supports_refund')::BOOLEAN, false),
            COALESCE((SELECT array_agg(x::VARCHAR(50)) FROM jsonb_array_elements_text(v_catalog->'features') x), '{}'),
            COALESCE((v_catalog->>'supports_recurring')::BOOLEAN, false),
            COALESCE((v_catalog->>'supports_tokenization')::BOOLEAN, false),
            COALESCE((v_catalog->>'requires_kyc_level')::SMALLINT, 0),
            COALESCE((v_catalog->>'requires_3ds')::BOOLEAN, false),
            COALESCE((v_catalog->>'requires_verification')::BOOLEAN, false),
            COALESCE((v_catalog->>'is_mobile')::BOOLEAN, true),
            COALESCE((v_catalog->>'is_desktop')::BOOLEAN, true),
            COALESCE((v_overrides->>'display_order')::INTEGER, 0),
            COALESCE((v_overrides->>'is_visible')::BOOLEAN, true),
            COALESCE((v_overrides->>'is_enabled')::BOOLEAN, true),
            COALESCE((v_overrides->>'is_featured')::BOOLEAN, false),
            COALESCE((SELECT array_agg(x::CHAR(2)) FROM jsonb_array_elements_text(v_overrides->'blocked_countries') x), '{}'),
            COALESCE((SELECT array_agg(x::CHAR(2)) FROM jsonb_array_elements_text(v_overrides->'allowed_countries') x), '{}'),
            COALESCE((SELECT array_agg(x::VARCHAR(20)) FROM jsonb_array_elements_text(v_overrides->'allowed_platforms') x), '{WEB,MOBILE,APP}'),
            v_catalog->>'deposit_processing_time',
            v_catalog->>'withdrawal_processing_time',
            p_rollout_status,
            NOW(),
            NOW(),
            NOW()
        );
    END IF;
END;
$$;

COMMENT ON FUNCTION finance.payment_method_settings_sync IS 'Syncs payment method catalog data from Core to Client DB. On INSERT: applies catalog + client overrides. On UPDATE: only catalog fields updated, client overrides preserved. Auth-agnostic (cross-DB auth pattern).';
