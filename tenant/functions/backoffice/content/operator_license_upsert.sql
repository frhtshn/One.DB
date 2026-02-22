-- ================================================================
-- OPERATOR_LICENSE_UPSERT: Operatör lisansı ekle / güncelle
-- (jurisdiction_id, license_number) üzerinden UPSERT yapılır
-- jurisdiction_id backend'de core.catalog.jurisdictions'a karşı doğrulanır
-- ================================================================

DROP FUNCTION IF EXISTS content.upsert_operator_license(INT, VARCHAR, VARCHAR, VARCHAR, VARCHAR[], DATE, DATE, SMALLINT, INTEGER);

CREATE OR REPLACE FUNCTION content.upsert_operator_license(
    p_jurisdiction_id   INT,
    p_license_number    VARCHAR(200),
    p_verification_url  VARCHAR(500)    DEFAULT NULL,
    p_logo_url          VARCHAR(500)    DEFAULT NULL,
    p_country_codes     VARCHAR(2)[]    DEFAULT '{}',
    p_issued_date       DATE            DEFAULT NULL,
    p_expiry_date       DATE            DEFAULT NULL,
    p_display_order     SMALLINT        DEFAULT 0,
    p_user_id           INTEGER         DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_id BIGINT;
BEGIN
    IF p_jurisdiction_id IS NULL THEN
        RAISE EXCEPTION 'error.operator-license.jurisdiction-required';
    END IF;
    IF p_license_number IS NULL OR TRIM(p_license_number) = '' THEN
        RAISE EXCEPTION 'error.operator-license.license-number-required';
    END IF;
    IF p_expiry_date IS NOT NULL AND p_issued_date IS NOT NULL AND p_expiry_date <= p_issued_date THEN
        RAISE EXCEPTION 'error.operator-license.expiry-before-issued';
    END IF;

    INSERT INTO content.operator_licenses (
        jurisdiction_id, license_number, verification_url, logo_url,
        country_codes, issued_date, expiry_date, display_order,
        created_by, updated_by
    )
    VALUES (
        p_jurisdiction_id, TRIM(p_license_number), p_verification_url, p_logo_url,
        COALESCE(p_country_codes, '{}'), p_issued_date, p_expiry_date,
        COALESCE(p_display_order, 0), p_user_id, p_user_id
    )
    ON CONFLICT ON CONSTRAINT uq_operator_license DO UPDATE SET
        verification_url = EXCLUDED.verification_url,
        logo_url         = EXCLUDED.logo_url,
        country_codes    = EXCLUDED.country_codes,
        issued_date      = EXCLUDED.issued_date,
        expiry_date      = EXCLUDED.expiry_date,
        display_order    = EXCLUDED.display_order,
        updated_by       = EXCLUDED.updated_by,
        updated_at       = NOW()
    RETURNING id INTO v_id;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION content.upsert_operator_license(INT, VARCHAR, VARCHAR, VARCHAR, VARCHAR[], DATE, DATE, SMALLINT, INTEGER) IS 'Insert or update an operator license by jurisdiction_id + license_number. jurisdiction_id must be validated by backend against core.catalog.jurisdictions. Returns the license ID.';
