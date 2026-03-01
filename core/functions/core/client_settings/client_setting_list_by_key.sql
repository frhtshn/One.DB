-- ================================================================
-- TENANT_SETTING_LIST_BY_KEY: Tum tenant'lar icin belirli bir key'in degerlerini doner
-- System-level fonksiyon, silo startup'ta bulk load icin kullanilir.
-- Access kontrolu YOK (caller_id parametresi yok).
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_setting_list_by_key(VARCHAR);

CREATE OR REPLACE FUNCTION core.tenant_setting_list_by_key(
    p_key VARCHAR
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'tenantId', ts.tenant_id,
                'value', ts.setting_value
            )
        )
        FROM core.tenant_settings ts
        INNER JOIN core.tenants t ON t.id = ts.tenant_id AND t.status = 1
        WHERE ts.setting_key = p_key
    ), '[]'::jsonb);
END;
$$;

COMMENT ON FUNCTION core.tenant_setting_list_by_key(VARCHAR) IS 'Returns all tenant values for a specific setting key. System-level, no access check. Used by silo startup for bulk config loading.';
