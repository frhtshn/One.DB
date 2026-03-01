-- ================================================================
-- CLIENT_PAYMENT_PROVIDER_ENABLE: Client'a payment provider aç + metotları seed et
-- ================================================================
-- Backend Finance DB'den ödeme metot listesini alır, p_method_data TEXT
-- olarak bu fonksiyona geçirir. Fonksiyon catalog sorgusu YAPMAZ.
-- Mevcut metotların is_enabled durumuna dokunmaz.
-- Yeni metotlar ON CONFLICT DO NOTHING ile seed edilir.
-- ================================================================

DROP FUNCTION IF EXISTS core.client_payment_provider_enable(BIGINT, BIGINT, BIGINT, TEXT, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION core.client_payment_provider_enable(
    p_caller_id BIGINT,
    p_client_id BIGINT,
    p_provider_id BIGINT,
    p_method_data TEXT DEFAULT NULL,
    p_mode VARCHAR(20) DEFAULT 'real',
    p_rollout_status VARCHAR(20) DEFAULT 'production'
)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_company_id BIGINT;
    v_methods JSONB;
    v_elem JSONB;
    v_count INTEGER := 0;
BEGIN
    -- Client varlık kontrolü
    SELECT company_id INTO v_company_id
    FROM core.clients WHERE id = p_client_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.client.not-found';
    END IF;

    -- IDOR kontrolü
    PERFORM security.user_assert_access_company(p_caller_id, v_company_id);

    -- Provider varlık + tip kontrolü
    IF NOT EXISTS(
        SELECT 1 FROM catalog.providers p
        JOIN catalog.provider_types pt ON pt.id = p.provider_type_id
        WHERE p.id = p_provider_id AND pt.provider_type_code = 'PAYMENT'
    ) THEN
        IF NOT EXISTS(SELECT 1 FROM catalog.providers WHERE id = p_provider_id) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.provider.not-found';
        ELSE
            RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provider.not-payment-type';
        END IF;
    END IF;

    -- rollout_status validasyon
    IF p_rollout_status NOT IN ('shadow', 'production') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provider.invalid-rollout-status';
    END IF;

    -- client_providers UPSERT
    INSERT INTO core.client_providers (client_id, provider_id, mode, is_enabled, rollout_status, created_at, updated_at)
    VALUES (p_client_id, p_provider_id, p_mode, true, p_rollout_status, NOW(), NOW())
    ON CONFLICT (client_id, provider_id) DO UPDATE SET
        is_enabled = true,
        mode = p_mode,
        rollout_status = p_rollout_status,
        updated_at = NOW();

    -- Ödeme metotlarını seed et (varsa)
    IF p_method_data IS NOT NULL AND TRIM(p_method_data) != '' THEN
        v_methods := p_method_data::JSONB;

        FOR v_elem IN SELECT * FROM jsonb_array_elements(v_methods)
        LOOP
            INSERT INTO core.client_payment_methods (
                client_id, payment_method_id, payment_method_name, payment_method_code,
                provider_code, payment_type, icon_url,
                sync_status, created_by, created_at, updated_at
            ) VALUES (
                p_client_id,
                (v_elem->>'payment_method_id')::BIGINT,
                v_elem->>'payment_method_name',
                v_elem->>'payment_method_code',
                v_elem->>'provider_code',
                v_elem->>'payment_type',
                v_elem->>'icon_url',
                'pending',
                p_caller_id,
                NOW(),
                NOW()
            )
            ON CONFLICT (client_id, payment_method_id) DO NOTHING;

            IF FOUND THEN
                v_count := v_count + 1;
            END IF;
        END LOOP;
    END IF;

    RETURN v_count;
END;
$$;

COMMENT ON FUNCTION core.client_payment_provider_enable IS 'Enables a PAYMENT provider for client and seeds payment methods from backend-provided data (cross-DB orchestration). Existing methods untouched (ON CONFLICT DO NOTHING). Supports shadow rollout mode.';
