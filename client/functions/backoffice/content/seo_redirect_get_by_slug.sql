-- ================================================================
-- SEO_REDIRECT_GET_BY_SLUG: Slug ile yönlendirme kuralını getir
-- Backend middleware her istek sırasında bu fonksiyonu sorgular
-- Sadece aktif kayıtlar döner
-- ================================================================

DROP FUNCTION IF EXISTS content.get_seo_redirect_by_slug(VARCHAR);

CREATE OR REPLACE FUNCTION content.get_seo_redirect_by_slug(
    p_from_slug VARCHAR(500)
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    IF p_from_slug IS NULL OR TRIM(p_from_slug) = '' THEN
        RETURN NULL;
    END IF;

    SELECT jsonb_build_object(
        'toUrl',        to_url,
        'redirectType', redirect_type
    )
    INTO v_result
    FROM content.seo_redirects
    WHERE from_slug = TRIM(p_from_slug)
      AND is_active = TRUE
    LIMIT 1;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION content.get_seo_redirect_by_slug(VARCHAR) IS 'Middleware lookup: returns {toUrl, redirectType} for an active redirect by from_slug. Returns NULL if no matching active redirect. Used on every HTTP request by backend routing middleware.';
