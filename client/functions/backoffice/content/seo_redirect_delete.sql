-- ================================================================
-- SEO_REDIRECT_DELETE: URL yönlendirme kuralını pasife al (soft delete)
-- ================================================================

DROP FUNCTION IF EXISTS content.delete_seo_redirect(BIGINT, INTEGER);

CREATE OR REPLACE FUNCTION content.delete_seo_redirect(
    p_id        BIGINT,
    p_user_id   INTEGER DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_id IS NULL THEN
        RAISE EXCEPTION 'error.seo-redirect.id-required';
    END IF;

    UPDATE content.seo_redirects
    SET
        is_active  = FALSE,
        updated_by = p_user_id,
        updated_at = NOW()
    WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'error.seo-redirect.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION content.delete_seo_redirect(BIGINT, INTEGER) IS 'Soft-delete a URL redirect rule by setting is_active = FALSE. Middleware will no longer serve this redirect.';
