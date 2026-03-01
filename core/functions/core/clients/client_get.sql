-- ================================================================
-- CLIENT_GET: Client detaylarını getirir
-- Company bilgileri ve desteklenen config listeleri ile döner.
-- GÜNCELLENDİ: Caller ID ile yetki kontrolü
-- ================================================================

DROP FUNCTION IF EXISTS core.client_get(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION core.client_get(p_caller_id BIGINT, p_id BIGINT)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
    v_client_company_id BIGINT;
BEGIN
    -- 1. Client varlık kontrolü
    SELECT company_id INTO v_client_company_id
    FROM core.clients WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.client.not-found';
    END IF;

    -- 2. Company erişim kontrolü
    PERFORM security.user_assert_access_company(p_caller_id, v_client_company_id);

    -- 4. Get Data
    SELECT jsonb_build_object(
        'id', t.id,
        'companyId', t.company_id,
        'companyName', c.company_name,
        'clientCode', t.client_code,
        'clientName', t.client_name,
        'environment', t.environment,
        'status', t.status,
        'baseCurrency', t.base_currency,
        'defaultLanguage', t.default_language,
        'defaultCountry', t.default_country,
        'timezone', t.timezone,
        'domain', t.domain,
        'subdomain', t.subdomain,
        'provisioningStatus', t.provisioning_status,
        'provisioningStep', t.provisioning_step,
        'provisionedAt', t.provisioned_at,
        'decommissionedAt', t.decommissioned_at,
        'hostingMode', t.hosting_mode,
        'createdAt', t.created_at,
        'updatedAt', t.updated_at,
        'supportedCurrencies', COALESCE((
            SELECT jsonb_agg(tc.currency_code ORDER BY tc.currency_code)
            FROM core.client_currencies tc
            WHERE tc.client_id = t.id AND tc.is_enabled = TRUE
        ), '[]'::jsonb),
        'supportedLanguages', COALESCE((
            SELECT jsonb_agg(tl.language_code ORDER BY tl.language_code)
            FROM core.client_languages tl
            WHERE tl.client_id = t.id AND tl.is_enabled = TRUE
        ), '[]'::jsonb)
    )
    INTO v_result
    FROM core.clients t
    JOIN core.companies c ON t.company_id = c.id
    WHERE t.id = p_id;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION core.client_get(BIGINT, BIGINT) IS 'Returns detailed client information. Checks caller permissions.';
