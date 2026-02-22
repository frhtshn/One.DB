-- ================================================================
-- CONTENT_SEO_STATUS_LIST: İçeriklerin SEO doluluk durumunu listele
-- Her çeviri için hangi SEO alanlarının doldurulduğunu gösterir
-- BO editörler için SEO önceliklendirme aracı
-- ================================================================

DROP FUNCTION IF EXISTS content.list_contents_seo_status(CHAR, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION content.list_contents_seo_status(
    p_language_code CHAR(2)     DEFAULT NULL,   -- NULL = tüm diller
    p_limit         INTEGER     DEFAULT 50,
    p_offset        INTEGER     DEFAULT 0
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_total INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_total
    FROM content.content_translations t
    JOIN content.contents c ON c.id = t.content_id
    WHERE c.is_active = TRUE
      AND (p_language_code IS NULL OR t.language_code = p_language_code);

    RETURN jsonb_build_object(
        'total', v_total,
        'items', (
            SELECT COALESCE(jsonb_agg(jsonb_build_object(
                'contentId',            t.content_id,
                'languageCode',         t.language_code,
                'slug',                 c.slug,
                'title',                t.title,
                'contentStatus',        c.status,
                'hasMetaTitle',         (t.meta_title IS NOT NULL AND t.meta_title <> ''),
                'hasMetaDescription',   (t.meta_description IS NOT NULL AND t.meta_description <> ''),
                'hasOgTitle',           (t.og_title IS NOT NULL AND t.og_title <> ''),
                'hasOgImage',           (t.og_image_url IS NOT NULL AND t.og_image_url <> ''),
                'hasTwitterCard',       (t.twitter_card IS NOT NULL AND t.twitter_card <> ''),
                'hasCanonicalUrl',      (t.canonical_url IS NOT NULL AND t.canonical_url <> ''),
                'robotsDirective',      t.robots_directive,
                'seoScore',             (
                    (CASE WHEN t.meta_title IS NOT NULL AND t.meta_title <> '' THEN 20 ELSE 0 END) +
                    (CASE WHEN t.meta_description IS NOT NULL AND t.meta_description <> '' THEN 20 ELSE 0 END) +
                    (CASE WHEN t.og_title IS NOT NULL AND t.og_title <> '' THEN 15 ELSE 0 END) +
                    (CASE WHEN t.og_image_url IS NOT NULL AND t.og_image_url <> '' THEN 15 ELSE 0 END) +
                    (CASE WHEN t.twitter_card IS NOT NULL AND t.twitter_card <> '' THEN 15 ELSE 0 END) +
                    (CASE WHEN t.canonical_url IS NOT NULL AND t.canonical_url <> '' THEN 15 ELSE 0 END)
                )
            ) ORDER BY c.id, t.language_code), '[]'::JSONB)
            FROM content.content_translations t
            JOIN content.contents c ON c.id = t.content_id
            WHERE c.is_active = TRUE
              AND (p_language_code IS NULL OR t.language_code = p_language_code)
            ORDER BY c.id, t.language_code
            LIMIT COALESCE(p_limit, 50)
            OFFSET COALESCE(p_offset, 0)
        )
    );
END;
$$;

COMMENT ON FUNCTION content.list_contents_seo_status(CHAR, INTEGER, INTEGER) IS 'List content translations with SEO completeness status and score (0-100). seoScore is weighted: metaTitle+metaDescription=40, og fields=30, twitter+canonical=30. Used by editors to prioritize SEO work.';
