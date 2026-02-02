-- ================================================================
-- TENANT_GET: Tenant detaylarını getirir
-- Company bilgileri ve desteklenen config listeleri ile döner.
-- GÜNCELLENDİ: Caller ID ile yetki kontrolü
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_get(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION core.tenant_get(p_caller_id BIGINT, p_id BIGINT)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
    v_caller_company_id BIGINT;
    v_has_platform_role BOOLEAN;
    v_tenant_company_id BIGINT;
    v_tenant_status SMALLINT;
BEGIN
    -- 1. Yetki ve Kullanıcı Kontrolü
    SELECT
        u.company_id,
        EXISTS(SELECT 1 FROM security.user_roles ur JOIN security.roles r ON ur.role_id = r.id WHERE ur.user_id = u.id AND ur.tenant_id IS NULL AND r.is_platform_role = TRUE)
    INTO v_caller_company_id, v_has_platform_role
    FROM security.users u
    WHERE u.id = p_caller_id AND u.status = 1;

    IF v_caller_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
    END IF;

    -- 2. Tenant Varlık Kontrolü
    SELECT company_id, status INTO v_tenant_company_id, v_tenant_status
    FROM core.tenants
    WHERE id = p_id;

    IF NOT FOUND THEN
         RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    -- 3. Scope Kontrolü
    IF NOT v_has_platform_role THEN
        IF v_tenant_company_id != v_caller_company_id THEN
            RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.company-scope-denied';
        END IF;
    END IF;

    -- 4. Get Data
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

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION core.tenant_get(BIGINT, BIGINT) IS 'Returns detailed tenant information. Checks caller permissions.';
