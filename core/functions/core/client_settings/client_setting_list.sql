-- ================================================================
-- TENANT_SETTING_LIST: Tenant'a ait tüm ayarları listeler
-- GÜNCELLENDİ: Caller ID ile yetki kontrolü
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_setting_list(BIGINT, BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION core.tenant_setting_list(
    p_caller_id BIGINT,
    p_tenant_id BIGINT,
    p_category VARCHAR DEFAULT NULL -- Optional filter
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
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

    -- 3. List Data
    RETURN COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'id', id,
                'tenantId', tenant_id,
                'category', category,
                'key', setting_key,
                'value', setting_value,
                'description', description,
                'updatedAt', updated_at
            ) ORDER BY category, setting_key
        )
        FROM core.tenant_settings
        WHERE tenant_id = p_tenant_id
        AND (p_category IS NULL OR category = p_category)
    ), '[]'::jsonb);
END;
$$;

COMMENT ON FUNCTION core.tenant_setting_list(BIGINT, BIGINT, VARCHAR) IS 'Lists configuration settings for a tenant. Checks caller permissions.';
