-- ================================================================
-- TENANT_CREATE: Yeni tenant oluşturur
-- Code benzersiz olmalı, Company ID geçerli olmalı.
-- Desteklenen para birimleri ve dilleri de otomatik ekler.
-- GÜNCELLENDİ: Caller ID ile yetki kontrolü
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_create(BIGINT, BIGINT, VARCHAR, VARCHAR, VARCHAR, CHAR(3), CHAR(2), CHAR(2), VARCHAR, VARCHAR[], VARCHAR[]);

CREATE OR REPLACE FUNCTION core.tenant_create(
    p_caller_id BIGINT,
    p_company_id BIGINT,
    p_tenant_code VARCHAR,
    p_tenant_name VARCHAR,
    p_environment VARCHAR DEFAULT 'prod',
    p_base_currency CHAR(3) DEFAULT NULL,
    p_default_language CHAR(2) DEFAULT NULL,
    p_default_country CHAR(2) DEFAULT NULL,
    p_timezone VARCHAR DEFAULT NULL,
    p_supported_currencies VARCHAR[] DEFAULT NULL, -- Array of currency codes
    p_supported_languages VARCHAR[] DEFAULT NULL   -- Array of language codes
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_id BIGINT;
    v_curr VARCHAR;
    v_lang VARCHAR;
    v_caller_company_id BIGINT;
    v_has_platform_role BOOLEAN;
BEGIN
    -- 1. Yetki Kontrolü
    SELECT
        u.company_id,
        EXISTS(SELECT 1 FROM security.user_roles ur JOIN security.roles r ON ur.role_id = r.id WHERE ur.user_id = u.id AND ur.tenant_id IS NULL AND r.is_platform_role = TRUE)
    INTO v_caller_company_id, v_has_platform_role
    FROM security.users u
    WHERE u.id = p_caller_id AND u.status = 1;

    IF v_caller_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.unauthorized';
    END IF;

    IF NOT v_has_platform_role THEN
        IF p_company_id != v_caller_company_id THEN
            RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.company-scope-denied';
        END IF;
    END IF;

    -- Company Exists Check
    IF NOT EXISTS (SELECT 1 FROM core.companies WHERE id = p_company_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.company.not-found';
    END IF;

    -- Tenant Code Unique Check
    IF EXISTS (SELECT 1 FROM core.tenants WHERE tenant_code = p_tenant_code) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.tenant.code-exists';
    END IF;

    -- Insert Tenant
    INSERT INTO core.tenants (
        company_id,
        tenant_code,
        tenant_name,
        environment,
        base_currency,
        default_language,
        default_country,
        timezone,
        status,
        created_at,
        updated_at
    ) VALUES (
        p_company_id,
        p_tenant_code,
        p_tenant_name,
        p_environment,
        p_base_currency,
        p_default_language,
        p_default_country,
        p_timezone,
        1, -- Active default
        NOW(),
        NOW()
    ) RETURNING core.tenants.id INTO v_id;

    -- Process Supported Currencies
    IF p_base_currency IS NOT NULL THEN
        INSERT INTO core.tenant_currencies (tenant_id, currency_code, is_enabled)
        VALUES (v_id, p_base_currency, TRUE)
        ON CONFLICT DO NOTHING;
    END IF;

    IF p_supported_currencies IS NOT NULL THEN
        FOREACH v_curr IN ARRAY p_supported_currencies
        LOOP
            IF v_curr IS NOT NULL AND v_curr <> p_base_currency THEN
                INSERT INTO core.tenant_currencies (tenant_id, currency_code, is_enabled)
                VALUES (v_id, v_curr, TRUE)
                ON CONFLICT (id) DO NOTHING;
            END IF;
        END LOOP;
    END IF;

    -- Process Supported Languages
    IF p_default_language IS NOT NULL THEN
        INSERT INTO core.tenant_languages (tenant_id, language_code, is_enabled)
        VALUES (v_id, p_default_language, TRUE)
        ON CONFLICT DO NOTHING;
    END IF;

    IF p_supported_languages IS NOT NULL THEN
        FOREACH v_lang IN ARRAY p_supported_languages
        LOOP
            IF v_lang IS NOT NULL AND v_lang <> p_default_language THEN
                INSERT INTO core.tenant_languages (tenant_id, language_code, is_enabled)
                VALUES (v_id, v_lang, TRUE)
                ON CONFLICT DO NOTHING;
            END IF;
        END LOOP;
    END IF;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION core.tenant_create(BIGINT, BIGINT, VARCHAR, VARCHAR, VARCHAR, CHAR(3), CHAR(2), CHAR(2), VARCHAR, VARCHAR[], VARCHAR[]) IS 'Creates a new tenant. Checks caller permissions.';
