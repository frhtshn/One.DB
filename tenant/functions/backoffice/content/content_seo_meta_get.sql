-- ================================================================
-- CONTENT_SEO_META_GET: İçerik çevirisi SEO meta verilerini getir
-- ================================================================

DROP FUNCTION IF EXISTS content.get_content_seo_meta(INTEGER, CHAR);

CREATE OR REPLACE FUNCTION content.get_content_seo_meta(
    p_content_id    INTEGER,
    p_language_code CHAR(2)
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    IF p_content_id IS NULL THEN
        RAISE EXCEPTION 'error.content-seo-meta.content-id-required';
    END IF;
    IF p_language_code IS NULL THEN
        RAISE EXCEPTION 'error.content-seo-meta.language-required';
    END IF;

    SELECT jsonb_build_object(
        'contentId',            t.content_id,
        'languageCode',         t.language_code,
        'title',                t.title,
        'metaTitle',            t.meta_title,
        'metaDescription',      t.meta_description,
        'metaKeywords',         t.meta_keywords,
        'ogTitle',              t.og_title,
        'ogDescription',        t.og_description,
        'ogImageUrl',           t.og_image_url,
        'twitterCard',          t.twitter_card,
        'twitterTitle',         t.twitter_title,
        'twitterDescription',   t.twitter_description,
        'twitterImageUrl',      t.twitter_image_url,
        'robotsDirective',      t.robots_directive,
        'canonicalUrl',         t.canonical_url,
        'slug',                 c.slug
    )
    INTO v_result
    FROM content.content_translations t
    JOIN content.contents c ON c.id = t.content_id
    WHERE t.content_id = p_content_id
      AND t.language_code = p_language_code;

    IF v_result IS NULL THEN
        RAISE EXCEPTION 'error.content-seo-meta.translation-not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION content.get_content_seo_meta(INTEGER, CHAR) IS 'Get all SEO metadata fields for a specific content translation, including content slug. Returns JSONB.';
