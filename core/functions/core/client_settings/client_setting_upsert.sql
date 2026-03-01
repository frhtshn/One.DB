-- ================================================================
-- TENANT_SETTING_UPSERT: Tenant ayarı ekler veya günceller
-- Key-Value yapısında çalışır. Key unique'dir (tenant bazında).
-- GÜNCELLENDİ: Caller ID ile yetki kontrolü
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_setting_upsert(BIGINT, BIGINT, VARCHAR, JSONB, VARCHAR, VARCHAR);
DROP FUNCTION IF EXISTS core.tenant_setting_upsert(BIGINT, BIGINT, VARCHAR, TEXT, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION core.tenant_setting_upsert(
    p_caller_id BIGINT,
    p_tenant_id BIGINT,
    p_key VARCHAR,
    p_value TEXT,
    p_description VARCHAR DEFAULT NULL,
    p_category VARCHAR DEFAULT 'General'
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

    -- 3. Upsert
    INSERT INTO core.tenant_settings (
        tenant_id,
        setting_key,
        setting_value,
        description,
        category,
        updated_at
    ) VALUES (
        p_tenant_id,
        p_key,
        p_value::jsonb,
        p_description,
        p_category,
        NOW()
    )
    ON CONFLICT (tenant_id, setting_key)
    DO UPDATE SET
        setting_value = EXCLUDED.setting_value,
        description = COALESCE(EXCLUDED.description, core.tenant_settings.description),
        category = COALESCE(EXCLUDED.category, core.tenant_settings.category),
        updated_at = NOW();
END;
$$;

COMMENT ON FUNCTION core.tenant_setting_upsert(BIGINT, BIGINT, VARCHAR, TEXT, VARCHAR, VARCHAR) IS 'Inserts or updates a tenant configuration setting. Checks caller permissions.';
