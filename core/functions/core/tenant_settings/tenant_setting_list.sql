-- ================================================================
-- TENANT_SETTING_LIST: Tenant'a ait tüm ayarları listeler
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_setting_list(BIGINT);

CREATE OR REPLACE FUNCTION core.tenant_setting_list(p_tenant_id BIGINT)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'id', id,
                'tenantId', tenant_id,
                'key', setting_key,
                'value', setting_value,
                'description', description,
                'updatedAt', updated_at
            ) ORDER BY setting_key
        )
        FROM core.tenant_settings
        WHERE tenant_id = p_tenant_id
    ), '[]'::jsonb);
END;
$$;

COMMENT ON FUNCTION core.tenant_setting_list(BIGINT) IS 'Lists all configuration settings for a tenant.';
