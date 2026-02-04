-- ================================================================
-- TENANT_UPDATE: Tenant bilgilerini günceller
-- Partial update destekler.
-- Supported Currencies/Languages listesi verilirse (NULL değilse) senkronize eder.
-- GÜNCELLENDİ: Caller ID ile yetki kontrolü
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_update(BIGINT, BIGINT, BIGINT, VARCHAR, VARCHAR, VARCHAR, CHAR(3), CHAR(2), CHAR(2), VARCHAR, SMALLINT, VARCHAR[], VARCHAR[]);

CREATE OR REPLACE FUNCTION core.tenant_update(
    p_caller_id BIGINT,
    p_id BIGINT,
    p_company_id BIGINT DEFAULT NULL,
    p_tenant_code VARCHAR DEFAULT NULL,
    p_tenant_name VARCHAR DEFAULT NULL,
    p_environment VARCHAR DEFAULT NULL,
    p_base_currency CHAR(3) DEFAULT NULL,
    p_default_language CHAR(2) DEFAULT NULL,
    p_default_country CHAR(2) DEFAULT NULL,
    p_timezone VARCHAR DEFAULT NULL,
    p_status SMALLINT DEFAULT NULL,
    p_supported_currencies VARCHAR[] DEFAULT NULL, -- Full list to sync
    p_supported_languages VARCHAR[] DEFAULT NULL   -- Full list to sync
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_curr VARCHAR;
    v_lang VARCHAR;
    v_current_base_currency CHAR(3);
    v_current_default_language CHAR(2);
    v_tenant_company_id BIGINT;
BEGIN
    -- 1. Tenant varlık kontrolü
    SELECT company_id INTO v_tenant_company_id
    FROM core.tenants WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    -- 2. Company erişim kontrolü (mevcut tenant'ın şirketine)
    PERFORM security.user_assert_access_company(p_caller_id, v_tenant_company_id);

    -- 3. Company değişikliği varsa hedef company'ye de erişim kontrolü
    IF p_company_id IS NOT NULL AND p_company_id != v_tenant_company_id THEN
        PERFORM security.user_assert_access_company(p_caller_id, p_company_id);
    END IF;

    -- Company Check (Target Company Exists)
    IF p_company_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM core.companies WHERE id = p_company_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.company.not-found';
    END IF;

    -- Code Unique Check
    IF p_tenant_code IS NOT NULL AND EXISTS (
        SELECT 1 FROM core.tenants WHERE tenant_code = p_tenant_code AND id <> p_id
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.tenant.code-exists';
    END IF;

    -- Update Tenant
    UPDATE core.tenants
    SET
        company_id = COALESCE(p_company_id, company_id),
        tenant_code = COALESCE(p_tenant_code, tenant_code),
        tenant_name = COALESCE(p_tenant_name, tenant_name),
        environment = COALESCE(p_environment, environment),
        base_currency = COALESCE(p_base_currency, base_currency),
        default_language = COALESCE(p_default_language, default_language),
        default_country = COALESCE(p_default_country, default_country),
        timezone = COALESCE(p_timezone, timezone),
        status = COALESCE(p_status, status),
        updated_at = NOW()
    WHERE id = p_id
    RETURNING base_currency, default_language INTO v_current_base_currency, v_current_default_language;

    -- Sync Currencies
    IF p_supported_currencies IS NOT NULL THEN
        UPDATE core.tenant_currencies SET is_enabled = FALSE WHERE tenant_id = p_id;

        FOREACH v_curr IN ARRAY p_supported_currencies
        LOOP
             IF EXISTS (SELECT 1 FROM core.tenant_currencies WHERE tenant_id = p_id AND currency_code = v_curr) THEN
                 UPDATE core.tenant_currencies SET is_enabled = TRUE WHERE tenant_id = p_id AND currency_code = v_curr;
             ELSE
                 INSERT INTO core.tenant_currencies (tenant_id, currency_code, is_enabled)
                 VALUES (p_id, v_curr, TRUE);
             END IF;
        END LOOP;

        IF v_current_base_currency IS NOT NULL THEN
             IF EXISTS (SELECT 1 FROM core.tenant_currencies WHERE tenant_id = p_id AND currency_code = v_current_base_currency) THEN
                 UPDATE core.tenant_currencies SET is_enabled = TRUE WHERE tenant_id = p_id AND currency_code = v_current_base_currency;
             ELSE
                 INSERT INTO core.tenant_currencies (tenant_id, currency_code, is_enabled)
                 VALUES (p_id, v_current_base_currency, TRUE);
             END IF;
        END IF;
    END IF;

    -- Sync Languages
    IF p_supported_languages IS NOT NULL THEN
        UPDATE core.tenant_languages SET is_enabled = FALSE WHERE tenant_id = p_id;

        FOREACH v_lang IN ARRAY p_supported_languages
        LOOP
             IF EXISTS (SELECT 1 FROM core.tenant_languages WHERE tenant_id = p_id AND language_code = v_lang) THEN
                 UPDATE core.tenant_languages SET is_enabled = TRUE WHERE tenant_id = p_id AND language_code = v_lang;
             ELSE
                 INSERT INTO core.tenant_languages (tenant_id, language_code, is_enabled)
                 VALUES (p_id, v_lang, TRUE);
             END IF;
        END LOOP;

        IF v_current_default_language IS NOT NULL THEN
             IF EXISTS (SELECT 1 FROM core.tenant_languages WHERE tenant_id = p_id AND language_code = v_current_default_language) THEN
                 UPDATE core.tenant_languages SET is_enabled = TRUE WHERE tenant_id = p_id AND language_code = v_current_default_language;
             ELSE
                 INSERT INTO core.tenant_languages (tenant_id, language_code, is_enabled)
                 VALUES (p_id, v_current_default_language, TRUE);
             END IF;
        END IF;
    END IF;

END;
$$;

COMMENT ON FUNCTION core.tenant_update(BIGINT, BIGINT, BIGINT, VARCHAR, VARCHAR, VARCHAR, CHAR(3), CHAR(2), CHAR(2), VARCHAR, SMALLINT, VARCHAR[], VARCHAR[]) IS 'Updates tenant details. Checks caller permissions.';
