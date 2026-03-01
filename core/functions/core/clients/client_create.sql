-- ================================================================
-- CLIENT_CREATE: Yeni client oluşturur
-- Code benzersiz olmalı, Company ID geçerli olmalı.
-- Desteklenen para birimleri ve dilleri de otomatik ekler.
-- GÜNCELLENDİ: Caller ID ile yetki kontrolü
-- ================================================================

DROP FUNCTION IF EXISTS core.client_create(BIGINT, BIGINT, VARCHAR, VARCHAR, VARCHAR, CHAR(3), CHAR(2), CHAR(2), VARCHAR, VARCHAR[], VARCHAR[], VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION core.client_create(
    p_caller_id BIGINT,
    p_company_id BIGINT,
    p_client_code VARCHAR,
    p_client_name VARCHAR,
    p_environment VARCHAR DEFAULT 'prod',
    p_base_currency CHAR(3) DEFAULT NULL,
    p_default_language CHAR(2) DEFAULT NULL,
    p_default_country CHAR(2) DEFAULT NULL,
    p_timezone VARCHAR DEFAULT NULL,
    p_supported_currencies VARCHAR[] DEFAULT NULL, -- Array of currency codes
    p_supported_languages VARCHAR[] DEFAULT NULL,  -- Array of language codes
    p_domain VARCHAR(255) DEFAULT NULL,
    p_hosting_mode VARCHAR(20) DEFAULT 'shared'
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_id BIGINT;
    v_curr VARCHAR;
    v_lang VARCHAR;
BEGIN
    -- 1. Company erişim kontrolü
    PERFORM security.user_assert_access_company(p_caller_id, p_company_id);

    -- Company Exists Check
    IF NOT EXISTS (SELECT 1 FROM core.companies WHERE id = p_company_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.company.not-found';
    END IF;

    -- Client Code Unique Check
    IF EXISTS (SELECT 1 FROM core.clients WHERE client_code = p_client_code) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.client.code-exists';
    END IF;

    -- Insert Client
    INSERT INTO core.clients (
        company_id,
        client_code,
        client_name,
        environment,
        base_currency,
        default_language,
        default_country,
        timezone,
        domain,
        hosting_mode,
        status,
        created_at,
        updated_at
    ) VALUES (
        p_company_id,
        p_client_code,
        p_client_name,
        p_environment,
        p_base_currency,
        p_default_language,
        p_default_country,
        p_timezone,
        p_domain,
        p_hosting_mode,
        1, -- Active default
        NOW(),
        NOW()
    ) RETURNING core.clients.id INTO v_id;

    -- Process Supported Currencies
    IF p_base_currency IS NOT NULL THEN
        INSERT INTO core.client_currencies (client_id, currency_code, is_enabled)
        VALUES (v_id, p_base_currency, TRUE)
        ON CONFLICT DO NOTHING;
    END IF;

    IF p_supported_currencies IS NOT NULL THEN
        FOREACH v_curr IN ARRAY p_supported_currencies
        LOOP
            IF v_curr IS NOT NULL AND v_curr <> p_base_currency THEN
                INSERT INTO core.client_currencies (client_id, currency_code, is_enabled)
                VALUES (v_id, v_curr, TRUE)
                ON CONFLICT (id) DO NOTHING;
            END IF;
        END LOOP;
    END IF;

    -- Process Supported Languages
    IF p_default_language IS NOT NULL THEN
        INSERT INTO core.client_languages (client_id, language_code, is_enabled)
        VALUES (v_id, p_default_language, TRUE)
        ON CONFLICT DO NOTHING;
    END IF;

    IF p_supported_languages IS NOT NULL THEN
        FOREACH v_lang IN ARRAY p_supported_languages
        LOOP
            IF v_lang IS NOT NULL AND v_lang <> p_default_language THEN
                INSERT INTO core.client_languages (client_id, language_code, is_enabled)
                VALUES (v_id, v_lang, TRUE)
                ON CONFLICT DO NOTHING;
            END IF;
        END LOOP;
    END IF;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION core.client_create(BIGINT, BIGINT, VARCHAR, VARCHAR, VARCHAR, CHAR(3), CHAR(2), CHAR(2), VARCHAR, VARCHAR[], VARCHAR[], VARCHAR, VARCHAR) IS 'Creates a new client with optional domain and hosting mode. Checks caller permissions.';
