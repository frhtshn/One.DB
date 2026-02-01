-- ================================================================
-- TENANT_SETTING_GET: Belirli bir ayarın değerini döner
-- Setting objesini JSONB olarak döner.
-- GÜNCELLENDİ: Caller ID ile yetki kontrolü
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_setting_get(BIGINT, BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION core.tenant_setting_get(
    p_caller_id BIGINT,
    p_tenant_id BIGINT,
    p_key VARCHAR
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
    v_caller_company_id BIGINT;
    v_has_platform_role BOOLEAN;
    v_tenant_company_id BIGINT;
BEGIN
    -- 1. Yetki ve Kullanıcı Kontrolü
    SELECT
        u.company_id,
        EXISTS(SELECT 1 FROM security.user_roles ur JOIN security.roles r ON ur.role_id = r.id WHERE ur.user_id = u.id AND r.is_platform_role = TRUE)
    INTO v_caller_company_id, v_has_platform_role
    FROM security.users u
    WHERE u.id = p_caller_id AND u.status = 1;

    IF v_caller_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
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

    -- 4. Get Data
    SELECT jsonb_build_object(
        'id', id,
        'tenantId', tenant_id,
        'category', category,
        'key', setting_key,
        'value', setting_value,
        'description', description,
        'updatedAt', updated_at
    )
    INTO v_result
    FROM core.tenant_settings
    WHERE tenant_id = p_tenant_id AND setting_key = p_key;

    RETURN v_result; -- Returns NULL if not found
END;
$$;

COMMENT ON FUNCTION core.tenant_setting_get(BIGINT, BIGINT, VARCHAR) IS 'Returns a specific tenant setting. Checks caller permissions.';
