-- ================================================================
-- OPERATOR_LICENSE_LIST: Operatör lisanslarını listele (BO paneli)
-- ================================================================

DROP FUNCTION IF EXISTS content.list_operator_licenses(BOOLEAN);

CREATE OR REPLACE FUNCTION content.list_operator_licenses(
    p_include_inactive  BOOLEAN DEFAULT FALSE
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN (
        SELECT COALESCE(jsonb_agg(row_to_json(t)::JSONB ORDER BY t.display_order, t.id), '[]'::JSONB)
        FROM (
            SELECT
                id,
                jurisdiction_id     AS "jurisdictionId",
                license_number      AS "licenseNumber",
                verification_url    AS "verificationUrl",
                logo_url            AS "logoUrl",
                country_codes       AS "countryCodes",
                issued_date         AS "issuedDate",
                expiry_date         AS "expiryDate",
                display_order       AS "displayOrder",
                is_active           AS "isActive",
                created_at          AS "createdAt",
                updated_at          AS "updatedAt"
            FROM content.operator_licenses
            WHERE (p_include_inactive OR is_active = TRUE)
            ORDER BY display_order, id
        ) t
    );
END;
$$;

COMMENT ON FUNCTION content.list_operator_licenses(BOOLEAN) IS 'List operator licenses for backoffice. Returns sorted JSONB array. Backend enriches with jurisdiction name/code from core DB.';
