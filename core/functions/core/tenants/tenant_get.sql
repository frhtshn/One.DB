-- ================================================================
-- TENANT_GET: Tenant detaylarını getirir
-- Company bilgileri ve desteklenen config listeleri ile birlikte döner.
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_get(BIGINT);

CREATE OR REPLACE FUNCTION core.tenant_get(p_id BIGINT)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'id', t.id,
        'companyId', t.company_id,
        'companyName', c.company_name,
        'tenantCode', t.tenant_code,
        'tenantName', t.tenant_name,
        'environment', t.environment,
        'status', t.status,
        'baseCurrency', t.base_currency,
        'defaultLanguage', t.default_language,
        'defaultCountry', t.default_country,
        'timezone', t.timezone,
        'createdAt', t.created_at,
        'updatedAt', t.updated_at,
        'supportedCurrencies', COALESCE((
            SELECT jsonb_agg(tc.currency_code ORDER BY tc.currency_code)
            FROM core.tenant_currencies tc
            WHERE tc.tenant_id = t.id AND tc.is_enabled = TRUE
        ), '[]'::jsonb),
        'supportedLanguages', COALESCE((
            SELECT jsonb_agg(tl.language_code ORDER BY tl.language_code)
            FROM core.tenant_languages tl
            WHERE tl.tenant_id = t.id AND tl.is_enabled = TRUE
        ), '[]'::jsonb)
    )
    INTO v_result
    FROM core.tenants t
    JOIN core.companies c ON t.company_id = c.id
    WHERE t.id = p_id;

    -- Tenant bulunamadıysa exception fırlat
    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION core.tenant_get(BIGINT) IS 'Returns detailed tenant information including supported configuration.';
