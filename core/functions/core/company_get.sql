
-- ================================================================
-- COMPANY_GET: Şirket detay bilgisi (ID ile)
-- Yönetim paneli için, şirketin detay bilgilerini ülke adı ile döner
-- Returns company details by id for management UI, with country name
-- ================================================================

DROP FUNCTION IF EXISTS core.company_get(BIGINT);

CREATE OR REPLACE FUNCTION core.company_get(
    p_id BIGINT
)
RETURNS TABLE (
    id BIGINT,
    company_code VARCHAR,
    company_name VARCHAR,
    status SMALLINT,
    country_code CHARACTER(2),
    country_name VARCHAR,
    timezone VARCHAR,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM core.companies WHERE id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.company.not-found';
    END IF;
    RETURN QUERY
    SELECT
        c.id,
        c.company_code,
        c.company_name,
        c.status,
        c.country_code,
        co.country_name,
        c.timezone,
        c.created_at,
        c.updated_at
    FROM core.companies c
    LEFT JOIN catalog.countries co ON co.country_code = c.country_code
    WHERE c.id = p_id;
END;
$$;

COMMENT ON FUNCTION core.company_get(BIGINT) IS 'Returns details of a company by id for management UI.';
