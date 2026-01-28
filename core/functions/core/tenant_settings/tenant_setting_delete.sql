-- ================================================================
-- TENANT_SETTING_DELETE: Ayarı siler
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_setting_delete(BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION core.tenant_setting_delete(
    p_tenant_id BIGINT,
    p_key VARCHAR
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM core.tenant_settings
    WHERE tenant_id = p_tenant_id AND setting_key = p_key;
END;
$$;

COMMENT ON FUNCTION core.tenant_setting_delete(BIGINT, VARCHAR) IS 'Deletes a tenant configuration setting.';
