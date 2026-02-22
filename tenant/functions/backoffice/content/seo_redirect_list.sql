-- ================================================================
-- SEO_REDIRECT_LIST: URL yönlendirme kurallarını listele (BO paneli)
-- Arama ve sayfalama destekli
-- ================================================================

DROP FUNCTION IF EXISTS content.list_seo_redirects(VARCHAR, BOOLEAN, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION content.list_seo_redirects(
    p_search            VARCHAR(200)    DEFAULT NULL,   -- from_slug veya to_url araması
    p_include_inactive  BOOLEAN         DEFAULT FALSE,
    p_limit             INTEGER         DEFAULT 50,
    p_offset            INTEGER         DEFAULT 0
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_total INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_total
    FROM content.seo_redirects
    WHERE (p_include_inactive OR is_active = TRUE)
      AND (p_search IS NULL OR from_slug ILIKE '%' || p_search || '%' OR to_url ILIKE '%' || p_search || '%');

    RETURN jsonb_build_object(
        'total', v_total,
        'items', (
            SELECT COALESCE(jsonb_agg(jsonb_build_object(
                'id',           id,
                'fromSlug',     from_slug,
                'toUrl',        to_url,
                'redirectType', redirect_type,
                'isActive',     is_active,
                'createdAt',    created_at,
                'updatedAt',    updated_at
            ) ORDER BY id DESC), '[]'::JSONB)
            FROM content.seo_redirects
            WHERE (p_include_inactive OR is_active = TRUE)
              AND (p_search IS NULL OR from_slug ILIKE '%' || p_search || '%' OR to_url ILIKE '%' || p_search || '%')
            ORDER BY id DESC
            LIMIT COALESCE(p_limit, 50)
            OFFSET COALESCE(p_offset, 0)
        )
    );
END;
$$;

COMMENT ON FUNCTION content.list_seo_redirects(VARCHAR, BOOLEAN, INTEGER, INTEGER) IS 'List URL redirect rules with optional search filter and pagination. Returns paginated JSONB with total count.';
