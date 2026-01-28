
-- ================================================================
-- COMPANY_CREATE: Yeni şirket oluştur
-- Yönetim paneli için yeni şirket kaydı ekler
-- Creates a new company record for management UI
-- ================================================================

DROP FUNCTION IF EXISTS core.company_create(VARCHAR, VARCHAR, CHARACTER(2), VARCHAR);

CREATE OR REPLACE FUNCTION core.company_create(
    p_company_code VARCHAR,
    p_company_name VARCHAR,
    p_country_code CHARACTER(2),
    p_timezone VARCHAR DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_id BIGINT;
BEGIN
    -- Şirket kodu benzersizliği kontrolü
    IF EXISTS (SELECT 1 FROM core.companies WHERE company_code = p_company_code) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.company.create.code-exists';
    END IF;

    -- Şirket adı benzersizliği kontrolü
    IF EXISTS (SELECT 1 FROM core.companies WHERE company_name = p_company_name) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.company.create.name-exists';
    END IF;

    -- Ülke kodu geçerliliği kontrolü
    IF p_country_code IS NOT NULL AND NOT EXISTS (SELECT 1 FROM catalog.countries WHERE country_code = p_country_code) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.country.not-found';
    END IF;

    INSERT INTO core.companies (company_code, company_name, country_code, timezone)
    VALUES (p_company_code, p_company_name, p_country_code, p_timezone)
    RETURNING id INTO v_id;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION core.company_create(VARCHAR, VARCHAR, CHARACTER(2), VARCHAR) IS 'Creates a new company record for management UI.';
