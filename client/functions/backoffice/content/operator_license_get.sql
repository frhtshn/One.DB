-- ================================================================
-- OPERATOR_LICENSE_GET: Operatör lisansını ID ile getir
-- ================================================================

DROP FUNCTION IF EXISTS content.get_operator_license(BIGINT);

CREATE OR REPLACE FUNCTION content.get_operator_license(
    p_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    IF p_id IS NULL THEN
        RAISE EXCEPTION 'error.operator-license.id-required';
    END IF;

    SELECT jsonb_build_object(
        'id',               id,
        'jurisdictionId',   jurisdiction_id,
        'licenseNumber',    license_number,
        'verificationUrl',  verification_url,
        'logoUrl',          logo_url,
        'countryCodes',     country_codes,
        'issuedDate',       issued_date,
        'expiryDate',       expiry_date,
        'displayOrder',     display_order,
        'isActive',         is_active,
        'createdAt',        created_at,
        'updatedAt',        updated_at,
        'createdBy',        created_by,
        'updatedBy',        updated_by
    )
    INTO v_result
    FROM content.operator_licenses
    WHERE id = p_id;

    IF v_result IS NULL THEN
        RAISE EXCEPTION 'error.operator-license.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION content.get_operator_license(BIGINT) IS 'Get a single operator license by ID. Returns JSONB or raises not-found error.';
