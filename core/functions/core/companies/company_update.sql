
-- ================================================================
-- COMPANY_UPDATE: Şirket bilgisi güncelle
-- Yönetim paneli için şirket bilgilerini günceller
-- Updates company information for management UI
-- ================================================================

DROP FUNCTION IF EXISTS core.company_update(BIGINT, VARCHAR, VARCHAR, SMALLINT, CHARACTER(2), VARCHAR);

CREATE OR REPLACE FUNCTION core.company_update(
    p_id BIGINT,
    p_company_code VARCHAR,
    p_company_name VARCHAR,
    p_status SMALLINT,
    p_country_code CHARACTER(2),
    p_timezone VARCHAR
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Şirket kodu benzersizliği kontrolü (güncellenen hariç)
    IF EXISTS (SELECT 1 FROM core.companies WHERE company_code = p_company_code AND id <> p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.company.update.code-exists';
    END IF;

    -- Şirket adı benzersizliği kontrolü (güncellenen hariç)
    IF EXISTS (SELECT 1 FROM core.companies WHERE company_name = p_company_name AND id <> p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.company.update.name-exists';
    END IF;

    -- Ülke kodu geçerliliği kontrolü
    IF p_country_code IS NOT NULL AND NOT EXISTS (SELECT 1 FROM catalog.countries WHERE country_code = p_country_code) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.country.not-found';
    END IF;

    UPDATE core.companies
    SET
        company_code = p_company_code,
        company_name = p_company_name,
        status = p_status,
        country_code = p_country_code,
        timezone = p_timezone,
        updated_at = now()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION core.company_update(BIGINT, VARCHAR, VARCHAR, SMALLINT, CHARACTER(2), VARCHAR) IS 'Updates company information for management UI.';
