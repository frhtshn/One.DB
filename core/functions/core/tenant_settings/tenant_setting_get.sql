-- ================================================================
-- TENANT_SETTING_GET: Belirli bir ayarın değerini döner
-- Setting objesini JSONB olarak döner.
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_setting_get(BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION core.tenant_setting_get(
    p_tenant_id BIGINT,
    p_key VARCHAR
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'id', id,
        'tenantId', tenant_id,
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

COMMENT ON FUNCTION core.tenant_setting_get(BIGINT, VARCHAR) IS 'Returns a specific tenant setting as JSON object. Returns NULL if not found.';
