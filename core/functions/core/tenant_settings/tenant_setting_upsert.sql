-- ================================================================
-- TENANT_SETTING_UPSERT: Tenant ayarı ekler veya günceller
-- Key-Value yapısında çalışır. Key unique'dir (tenant bazında).
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_setting_upsert(BIGINT, VARCHAR, JSONB, VARCHAR);

CREATE OR REPLACE FUNCTION core.tenant_setting_upsert(
    p_tenant_id BIGINT,
    p_key VARCHAR,
    p_value JSONB,
    p_description VARCHAR DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Tenant Check
    IF NOT EXISTS (SELECT 1 FROM core.tenants WHERE id = p_tenant_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    -- Upsert
    INSERT INTO core.tenant_settings (
        tenant_id,
        setting_key,
        setting_value,
        description,
        updated_at
    ) VALUES (
        p_tenant_id,
        p_key,
        p_value,
        p_description,
        NOW()
    )
    ON CONFLICT (tenant_id, setting_key)
    DO UPDATE SET
        setting_value = EXCLUDED.setting_value,
        description = COALESCE(EXCLUDED.description, core.tenant_settings.description),
        updated_at = NOW();
END;
$$;

COMMENT ON FUNCTION core.tenant_setting_upsert(BIGINT, VARCHAR, JSONB, VARCHAR) IS 'Inserts or updates a tenant configuration setting.';
