-- ================================================================
-- TENANT_PAYMENT_METHOD_REFRESH: Yeni ödeme metotlarını toplu seed et
-- ================================================================
-- Backend Finance DB'den yeni metot listesini alıp bu fonksiyona geçirir.
-- Mevcut kayıtlara dokunmaz (ON CONFLICT DO NOTHING).
-- Provider tip kontrolü yapılır (PAYMENT olmalı).
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_payment_method_refresh(BIGINT, BIGINT, BIGINT, TEXT);

CREATE OR REPLACE FUNCTION core.tenant_payment_method_refresh(
    p_caller_id BIGINT,
    p_tenant_id BIGINT,
    p_provider_id BIGINT,
    p_method_data TEXT
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
    -- Tenant varlık kontrolü
    SELECT company_id INTO v_company_id
    FROM core.tenants WHERE id = p_tenant_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    -- IDOR kontrolü
    PERFORM security.user_assert_access_company(p_caller_id, v_company_id);

    -- Provider tip kontrolü (PAYMENT olmalı)
    IF NOT EXISTS(
        SELECT 1 FROM catalog.providers p
        JOIN catalog.provider_types pt ON pt.id = p.provider_type_id
        WHERE p.id = p_provider_id AND pt.provider_type_code = 'PAYMENT'
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provider.not-payment-type';
    END IF;

    -- Veri kontrolü
    IF p_method_data IS NULL OR TRIM(p_method_data) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.payment-method.data-required';
    END IF;

    v_methods := p_method_data::JSONB;

    -- Yeni metotları seed et
    FOR v_elem IN SELECT * FROM jsonb_array_elements(v_methods)
    LOOP
        INSERT INTO core.tenant_payment_methods (
            tenant_id, payment_method_id, payment_method_name, payment_method_code,
            provider_code, payment_type, icon_url,
            sync_status, created_by, created_at, updated_at
        ) VALUES (
            p_tenant_id,
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
        ON CONFLICT (tenant_id, payment_method_id) DO NOTHING;

        IF FOUND THEN
            v_count := v_count + 1;
        END IF;
    END LOOP;

    RETURN v_count;
END;
$$;

COMMENT ON FUNCTION core.tenant_payment_method_refresh IS 'Seeds new payment methods for a tenant from backend-provided data (cross-DB orchestration). Existing methods untouched (ON CONFLICT DO NOTHING). Returns inserted count. IDOR protected.';
