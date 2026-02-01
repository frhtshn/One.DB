-- ================================================================
-- TENANT_SETTING_UPSERT: Tenant ayarı ekler veya günceller
-- Key-Value yapısında çalışır. Key unique'dir (tenant bazında).
-- GÜNCELLENDİ: Caller ID ile yetki kontrolü
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_setting_upsert(BIGINT, BIGINT, VARCHAR, JSONB, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION core.tenant_setting_upsert(
    p_caller_id BIGINT,
    p_tenant_id BIGINT,
    p_key VARCHAR,
    p_value JSONB,
    p_description VARCHAR DEFAULT NULL,
    p_category VARCHAR DEFAULT 'General'
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_caller_company_id BIGINT;
    v_has_platform_role BOOLEAN;
    v_tenant_company_id BIGINT;
BEGIN
    -- 1. Yetki ve Kullanıcı Kontrolü
    SELECT
        u.company_id,
        EXISTS(SELECT 1 FROM security.user_roles ur JOIN security.roles r ON ur.role_id = r.id WHERE ur.user_id = u.id AND r.is_platform_role = TRUE)
    INTO v_caller_company_id, v_has_platform_role
    FROM security.users u
    WHERE u.id = p_caller_id AND u.status = 1;

    IF v_caller_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
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

    -- 4. Upsert
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
        p_value,
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

COMMENT ON FUNCTION core.tenant_setting_upsert(BIGINT, BIGINT, VARCHAR, JSONB, VARCHAR, VARCHAR) IS 'Inserts or updates a tenant configuration setting. Checks caller permissions.';
