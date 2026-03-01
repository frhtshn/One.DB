-- ================================================================
-- TENANT_SETTING_DELETE: Ayarı siler
-- GÜNCELLENDİ: Caller ID ile yetki kontrolü
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_setting_delete(BIGINT, BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION core.tenant_setting_delete(
    p_caller_id BIGINT,
    p_tenant_id BIGINT,
    p_key VARCHAR
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
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

    -- 3. Delete
    DELETE FROM core.tenant_settings
    WHERE tenant_id = p_tenant_id AND setting_key = p_key;
END;
$$;

COMMENT ON FUNCTION core.tenant_setting_delete(BIGINT, BIGINT, VARCHAR) IS 'Deletes a tenant configuration setting. Checks caller permissions.';
