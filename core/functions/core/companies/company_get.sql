
-- ================================================================
-- COMPANY_GET: Şirket detay bilgisi (ID ile)
-- Yönetim paneli için, şirketin detay bilgilerini ülke adı ile döner
-- Returns company details by id for management UI, with country name
-- ================================================================

DROP FUNCTION IF EXISTS core.company_get(BIGINT);

CREATE OR REPLACE FUNCTION core.company_get(
    p_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'id', c.id,
        'companyCode', c.company_code,
        'companyName', c.company_name,
        'status', c.status,
        'countryCode', c.country_code,
        'countryName', co.country_name,
        'timezone', c.timezone,
        'createdAt', c.created_at,
        'updatedAt', c.updated_at
    )
    INTO v_result
    FROM core.companies c
    LEFT JOIN catalog.countries co ON co.country_code = c.country_code
    WHERE c.id = p_id;

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.company.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION core.company_get(BIGINT) IS 'Returns details of a company by id for management UI.';
