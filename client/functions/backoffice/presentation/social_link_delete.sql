-- ================================================================
-- SOCIAL_LINK_DELETE: Sosyal medya linkini pasife al (soft delete)
-- ================================================================

DROP FUNCTION IF EXISTS presentation.delete_social_link(BIGINT, INTEGER);

CREATE OR REPLACE FUNCTION presentation.delete_social_link(
    p_id        BIGINT,
    p_user_id   INTEGER DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_id IS NULL THEN
        RAISE EXCEPTION 'error.social-link.id-required';
    END IF;

    UPDATE presentation.social_links
    SET
        is_active  = FALSE,
        updated_by = p_user_id,
        updated_at = NOW()
    WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'error.social-link.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION presentation.delete_social_link(BIGINT, INTEGER) IS 'Soft-delete a social link by setting is_active = FALSE.';
