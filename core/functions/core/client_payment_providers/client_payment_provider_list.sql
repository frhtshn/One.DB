-- ================================================================
-- TENANT_PAYMENT_PROVIDER_LIST: Tenant payment provider listesi
-- ================================================================
-- Sadece PAYMENT tipli provider'ları döner.
-- methodCount subquery ile ödeme metot sayısı eklenir.
-- rolloutStatus shadow mode durumunu gösterir.
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_payment_provider_list(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION core.tenant_payment_provider_list(
    p_caller_id BIGINT,
    p_tenant_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
    v_company_id BIGINT;
    v_result JSONB;
BEGIN
    -- Tenant varlık kontrolü
    SELECT company_id INTO v_company_id
    FROM core.tenants WHERE id = p_tenant_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    -- IDOR kontrolü
    PERFORM security.user_assert_access_company(p_caller_id, v_company_id);

    -- Provider listesi
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', tp.id,
            'providerId', tp.provider_id,
            'providerCode', p.provider_code,
            'providerName', p.provider_name,
            'mode', tp.mode,
            'isEnabled', tp.is_enabled,
            'rolloutStatus', tp.rollout_status,
            'methodCount', (
                SELECT COUNT(*)
                FROM core.tenant_payment_methods tpm
                WHERE tpm.tenant_id = tp.tenant_id
                  AND tpm.provider_code = p.provider_code
            ),
            'createdAt', tp.created_at,
            'updatedAt', tp.updated_at
        ) ORDER BY p.provider_name
    ), '[]'::jsonb)
    INTO v_result
    FROM core.tenant_providers tp
    JOIN catalog.providers p ON p.id = tp.provider_id
    JOIN catalog.provider_types pt ON pt.id = p.provider_type_id
    WHERE tp.tenant_id = p_tenant_id
      AND pt.provider_type_code = 'PAYMENT';

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION core.tenant_payment_provider_list IS 'Returns PAYMENT-type provider list for a tenant with method counts and rollout status. IDOR protected.';
