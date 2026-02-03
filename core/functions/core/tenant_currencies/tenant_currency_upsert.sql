-- ================================================================
-- TENANT_CURRENCY_UPSERT: Tenant para birimi ekle/güncelle
-- GÜNCELLENDİ: Caller ID ile yetki kontrolü
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_currency_upsert(BIGINT, BIGINT, CHAR(3), BOOLEAN);

CREATE OR REPLACE FUNCTION core.tenant_currency_upsert(
    p_caller_id BIGINT,
    p_tenant_id BIGINT,
    p_currency_code CHAR(3),
    p_is_enabled BOOLEAN DEFAULT TRUE
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
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

    -- 2. Tenant Varlık Kontrolü
    SELECT company_id INTO v_tenant_company_id
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

    -- 4. Currency Validation
    IF NOT EXISTS (SELECT 1 FROM catalog.currencies WHERE currency_code = p_currency_code AND is_active = TRUE) THEN
         RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.currency.not-found';
    END IF;

    -- 5. Upsert Logic
    IF EXISTS (SELECT 1 FROM core.tenant_currencies WHERE tenant_id = p_tenant_id AND currency_code = p_currency_code) THEN
        UPDATE core.tenant_currencies
        SET is_enabled = p_is_enabled,
            updated_at = NOW()
        WHERE tenant_id = p_tenant_id AND currency_code = p_currency_code;
    ELSE
        INSERT INTO core.tenant_currencies (tenant_id, currency_code, is_enabled)
        VALUES (p_tenant_id, p_currency_code, p_is_enabled);
    END IF;
END;
$$;

COMMENT ON FUNCTION core.tenant_currency_upsert(BIGINT, BIGINT, CHAR(3), BOOLEAN) IS 'Assigns or updates a currency for a tenant. Checks caller permissions.';
