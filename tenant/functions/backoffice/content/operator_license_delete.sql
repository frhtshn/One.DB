-- ================================================================
-- OPERATOR_LICENSE_DELETE: Operatör lisansını pasife al (soft delete)
-- ================================================================

DROP FUNCTION IF EXISTS content.delete_operator_license(BIGINT, INTEGER);

CREATE OR REPLACE FUNCTION content.delete_operator_license(
    p_id        BIGINT,
    p_user_id   INTEGER DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_id IS NULL THEN
        RAISE EXCEPTION 'error.operator-license.id-required';
    END IF;

    UPDATE content.operator_licenses
    SET
        is_active  = FALSE,
        updated_by = p_user_id,
        updated_at = NOW()
    WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'error.operator-license.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION content.delete_operator_license(BIGINT, INTEGER) IS 'Soft-delete an operator license by setting is_active = FALSE.';
