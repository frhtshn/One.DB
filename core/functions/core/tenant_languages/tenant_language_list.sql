-- ================================================================
-- TENANT_LANGUAGE_LIST: Tenant dillerini listeler
-- Default language bilgisini isDefault olarak işaretler.
-- GÜNCELLENDİ: Caller ID ile yetki kontrolü
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_language_list(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION core.tenant_language_list(
    p_caller_id BIGINT,
    p_tenant_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_default_language CHAR(2);
    v_result JSONB;
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

    -- 2. Tenant Varlık Kontrolü ve Default Language Alımı
    SELECT company_id, default_language INTO v_tenant_company_id, v_default_language
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
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', tl.id,
            'tenantId', tl.tenant_id,
            'code', tl.language_code,
            'name', l.language_name,
            'isEnabled', tl.is_enabled,
            'isDefault', (tl.language_code = v_default_language),
            'createdAt', tl.created_at,
            'updatedAt', tl.updated_at
        ) ORDER BY (tl.language_code = v_default_language) DESC, tl.is_enabled DESC, l.language_name
    ), '[]'::jsonb)
    INTO v_result
    FROM core.tenant_languages tl
    JOIN catalog.languages l ON l.language_code = tl.language_code
    WHERE tl.tenant_id = p_tenant_id;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION core.tenant_language_list(BIGINT, BIGINT) IS 'Lists all assigned languages for a tenant. Checks caller permissions.';
