-- ================================================================
-- TRUST_LOGO_DELETE: Güven logosunu pasife al (soft delete)
-- ================================================================

DROP FUNCTION IF EXISTS content.delete_trust_logo(BIGINT, INTEGER);

CREATE OR REPLACE FUNCTION content.delete_trust_logo(
    p_id        BIGINT,
    p_user_id   INTEGER DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_id IS NULL THEN
        RAISE EXCEPTION 'error.trust-logo.id-required';
    END IF;

    UPDATE content.trust_logos
    SET
        is_active  = FALSE,
        updated_by = p_user_id,
        updated_at = NOW()
    WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'error.trust-logo.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION content.delete_trust_logo(BIGINT, INTEGER) IS 'Soft-delete a trust logo by setting is_active = FALSE.';
