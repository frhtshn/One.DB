-- ================================================================
-- SEO_REDIRECT_UPSERT: URL yönlendirme kuralı ekle / güncelle
-- from_slug üzerinden UPSERT yapılır
-- ================================================================

DROP FUNCTION IF EXISTS content.upsert_seo_redirect(VARCHAR, VARCHAR, SMALLINT, INTEGER);

CREATE OR REPLACE FUNCTION content.upsert_seo_redirect(
    p_from_slug         VARCHAR(500),
    p_to_url            VARCHAR(500),
    p_redirect_type     SMALLINT    DEFAULT 301,
    p_user_id           INTEGER     DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_id BIGINT;
BEGIN
    IF p_from_slug IS NULL OR TRIM(p_from_slug) = '' THEN
        RAISE EXCEPTION 'error.seo-redirect.from-slug-required';
    END IF;
    IF p_to_url IS NULL OR TRIM(p_to_url) = '' THEN
        RAISE EXCEPTION 'error.seo-redirect.to-url-required';
    END IF;
    IF COALESCE(p_redirect_type, 301) NOT IN (301, 302) THEN
        RAISE EXCEPTION 'error.seo-redirect.invalid-redirect-type';
    END IF;
    IF LOWER(TRIM(p_from_slug)) = LOWER(TRIM(p_to_url)) THEN
        RAISE EXCEPTION 'error.seo-redirect.circular-redirect';
    END IF;

    INSERT INTO content.seo_redirects (
        from_slug, to_url, redirect_type, created_by, updated_by
    )
    VALUES (
        TRIM(p_from_slug), TRIM(p_to_url), COALESCE(p_redirect_type, 301),
        p_user_id, p_user_id
    )
    ON CONFLICT (from_slug) DO UPDATE SET
        to_url          = EXCLUDED.to_url,
        redirect_type   = EXCLUDED.redirect_type,
        is_active       = TRUE,
        updated_by      = EXCLUDED.updated_by,
        updated_at      = NOW()
    RETURNING id INTO v_id;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION content.upsert_seo_redirect(VARCHAR, VARCHAR, SMALLINT, INTEGER) IS 'Insert or update a URL redirect rule by from_slug. redirect_type must be 301 (permanent) or 302 (temporary). Reactivates previously disabled redirects on conflict. Returns the redirect ID.';
