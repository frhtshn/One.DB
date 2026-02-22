-- ================================================================
-- SEO_REDIRECT_BULK_IMPORT: URL yönlendirmelerini toplu içe aktar
-- p_items: [{fromSlug, toUrl, redirectType}] dizisi
-- Mevcut kayıtları günceller (UPSERT), yenileri ekler
-- ================================================================

DROP FUNCTION IF EXISTS content.bulk_import_seo_redirects(JSONB, INTEGER);

CREATE OR REPLACE FUNCTION content.bulk_import_seo_redirects(
    p_items     JSONB,
    p_user_id   INTEGER DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_item      JSONB;
    v_inserted  INTEGER := 0;
    v_updated   INTEGER := 0;
    v_skipped   INTEGER := 0;
    v_from_slug TEXT;
    v_to_url    TEXT;
    v_type      SMALLINT;
BEGIN
    IF p_items IS NULL OR jsonb_array_length(p_items) = 0 THEN
        RAISE EXCEPTION 'error.seo-redirect.items-required';
    END IF;

    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        v_from_slug := TRIM(v_item ->> 'fromSlug');
        v_to_url    := TRIM(v_item ->> 'toUrl');
        v_type      := COALESCE((v_item ->> 'redirectType')::SMALLINT, 301);

        -- Temel doğrulama
        IF v_from_slug IS NULL OR v_from_slug = '' OR v_to_url IS NULL OR v_to_url = '' THEN
            v_skipped := v_skipped + 1;
            CONTINUE;
        END IF;
        IF v_type NOT IN (301, 302) THEN
            v_skipped := v_skipped + 1;
            CONTINUE;
        END IF;

        INSERT INTO content.seo_redirects (
            from_slug, to_url, redirect_type, created_by, updated_by
        )
        VALUES (v_from_slug, v_to_url, v_type, p_user_id, p_user_id)
        ON CONFLICT (from_slug) DO UPDATE SET
            to_url        = EXCLUDED.to_url,
            redirect_type = EXCLUDED.redirect_type,
            is_active     = TRUE,
            updated_by    = EXCLUDED.updated_by,
            updated_at    = NOW();

        IF xmax = 0 THEN  -- INSERT oldu
            v_inserted := v_inserted + 1;
        ELSE              -- UPDATE oldu
            v_updated := v_updated + 1;
        END IF;
    END LOOP;

    RETURN jsonb_build_object(
        'inserted', v_inserted,
        'updated',  v_updated,
        'skipped',  v_skipped
    );
END;
$$;

COMMENT ON FUNCTION content.bulk_import_seo_redirects(JSONB, INTEGER) IS 'Bulk import URL redirect rules from a JSONB array of {fromSlug, toUrl, redirectType}. Invalid items are skipped. Returns {inserted, updated, skipped} counts.';
