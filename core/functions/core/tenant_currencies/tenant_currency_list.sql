-- ================================================================
-- TENANT_CURRENCY_LIST: Tenant para birimlerini listeler
-- Base currency bilgisini isBase olarak işaretler.
-- GÜNCELLENDİ: Caller ID ile yetki kontrolü
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_currency_list(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION core.tenant_currency_list(
    p_caller_id BIGINT,
    p_tenant_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_base_currency CHAR(3);
    v_result JSONB;
    v_caller_company_id BIGINT;
    v_has_platform_role BOOLEAN;
    v_tenant_company_id BIGINT;
BEGIN
    -- 1. Yetki ve Kullanıcı Kontrolü
    SELECT
        u.company_id,
        EXISTS(SELECT 1 FROM security.user_roles ur JOIN security.roles r ON ur.role_id = r.id WHERE ur.user_id = u.id AND ur.tenant_id IS NULL AND r.is_platform_role = TRUE)
    INTO v_caller_company_id, v_has_platform_role
    FROM security.users u
    WHERE u.id = p_caller_id AND u.status = 1;

    IF v_caller_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.unauthorized';
    END IF;

    -- 2. Tenant Varlık Kontrolü ve Base Currency Alımı
    SELECT company_id, base_currency INTO v_tenant_company_id, v_base_currency
    FROM core.tenants
    WHERE id = p_tenant_id;

    IF NOT FOUND THEN
         RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    -- 3. Scope Kontrolü
    IF NOT v_has_platform_role THEN
        IF v_tenant_company_id != v_caller_company_id THEN
            RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.company-scope-denied';
        END IF;
    END IF;

    -- 4. List Data
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', tc.id,
            'tenantId', tc.tenant_id,
            'code', tc.currency_code,
            'name', c.currency_name,
            'symbol', c.symbol,
            'isEnabled', tc.is_enabled,
            'isBase', (tc.currency_code = v_base_currency),
            'createdAt', tc.created_at,
            'updatedAt', tc.updated_at
        ) ORDER BY (tc.currency_code = v_base_currency) DESC, tc.is_enabled DESC, c.currency_name
    ), '[]'::jsonb)
    INTO v_result
    FROM core.tenant_currencies tc
    JOIN catalog.currencies c ON c.currency_code = tc.currency_code
    WHERE tc.tenant_id = p_tenant_id;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION core.tenant_currency_list(BIGINT, BIGINT) IS 'Lists all assigned currencies for a tenant. Checks caller permissions.';
