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
    v_caller_company_id BIGINT;
    v_has_platform_role BOOLEAN;
    v_tenant_company_id BIGINT;
BEGIN
    -- 1. Yetki ve Kullanıcı Kontrolü
    SELECT
        u.company_id,
        EXISTS(SELECT 1 FROM security.user_roles ur JOIN security.roles r ON ur.role_id = r.id WHERE ur.user_id = u.id AND ur.tenant_id IS NULL AND r.is_platform_role = TRUE)
    INTO v_caller_company_id, v_has_platform_role
    FROM security.users u
    WHERE u.id = p_caller_id AND u.status = 1;

    IF v_caller_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.unauthorized';
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

    -- 4. List Data
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
