-- ================================================================
-- CONTENT_SEO_META_UPDATE: İçerik çevirisi SEO meta alanlarını güncelle
-- OG, Twitter Card, robots ve canonical alanlarını günceller
-- ================================================================

DROP FUNCTION IF EXISTS content.update_content_seo_meta(INTEGER, CHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, INTEGER);

CREATE OR REPLACE FUNCTION content.update_content_seo_meta(
    p_content_id            INTEGER,
    p_language_code         CHAR(2),
    p_meta_title            VARCHAR(255)    DEFAULT NULL,
    p_meta_description      VARCHAR(500)    DEFAULT NULL,
    p_meta_keywords         VARCHAR(500)    DEFAULT NULL,
    p_og_title              VARCHAR(200)    DEFAULT NULL,
    p_og_description        VARCHAR(500)    DEFAULT NULL,
    p_og_image_url          VARCHAR(500)    DEFAULT NULL,
    p_twitter_card          VARCHAR(30)     DEFAULT NULL,
    p_twitter_title         VARCHAR(200)    DEFAULT NULL,
    p_twitter_description   VARCHAR(500)    DEFAULT NULL,
    p_twitter_image_url     VARCHAR(500)    DEFAULT NULL,
    p_robots_directive      VARCHAR(100)    DEFAULT NULL,
    p_canonical_url         VARCHAR(500)    DEFAULT NULL,
    p_user_id               INTEGER         DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_content_id IS NULL THEN
        RAISE EXCEPTION 'error.content-seo-meta.content-id-required';
    END IF;
    IF p_language_code IS NULL THEN
        RAISE EXCEPTION 'error.content-seo-meta.language-required';
    END IF;
    IF p_twitter_card IS NOT NULL AND p_twitter_card NOT IN ('summary', 'summary_large_image', 'app', 'player') THEN
        RAISE EXCEPTION 'error.content-seo-meta.invalid-twitter-card';
    END IF;

    UPDATE content.content_translations
    SET
        meta_title          = COALESCE(p_meta_title, meta_title),
        meta_description    = COALESCE(p_meta_description, meta_description),
        meta_keywords       = COALESCE(p_meta_keywords, meta_keywords),
        og_title            = COALESCE(p_og_title, og_title),
        og_description      = COALESCE(p_og_description, og_description),
        og_image_url        = COALESCE(p_og_image_url, og_image_url),
        twitter_card        = COALESCE(p_twitter_card, twitter_card),
        twitter_title       = COALESCE(p_twitter_title, twitter_title),
        twitter_description = COALESCE(p_twitter_description, twitter_description),
        twitter_image_url   = COALESCE(p_twitter_image_url, twitter_image_url),
        robots_directive    = COALESCE(p_robots_directive, robots_directive),
        canonical_url       = COALESCE(p_canonical_url, canonical_url),
        updated_by          = p_user_id,
        updated_at          = NOW()
    WHERE content_id = p_content_id
      AND language_code = p_language_code;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'error.content-seo-meta.translation-not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION content.update_content_seo_meta(INTEGER, CHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, INTEGER) IS 'Update SEO metadata fields (OG, Twitter Card, robots, canonical) for a specific content translation. Only non-null parameters are updated.';
