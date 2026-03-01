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
    v_tenant_company_id BIGINT;
BEGIN
    -- 1. Tenant varlık kontrolü
    SELECT company_id INTO v_tenant_company_id
    FROM core.tenants WHERE id = p_tenant_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    -- 2. Company erişim kontrolü
    PERFORM security.user_assert_access_company(p_caller_id, v_tenant_company_id);

    -- 3. Get Data
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
