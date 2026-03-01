-- ================================================================
-- THEME_UPSERT: Tema seç ve config override ayarla
-- theme_id core DB'deki catalog.themes referansıdır
-- Backend önce core'dan tema varlığını doğrular
-- ================================================================

DROP FUNCTION IF EXISTS presentation.theme_upsert(INT, JSONB, TEXT);

CREATE OR REPLACE FUNCTION presentation.theme_upsert(
    p_theme_id          INT,                -- Catalog tema ID (backend core'dan doğrular)
    p_config            JSONB   DEFAULT '{}',  -- Config override: {colors: {primary: "#123"}, logo_url: "..."}
    p_custom_css        TEXT    DEFAULT NULL    -- İleri düzey CSS override
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_id BIGINT;
BEGIN
    -- Parametre doğrulama
    IF p_theme_id IS NULL THEN
        RAISE EXCEPTION 'error.theme.theme-id-required';
    END IF;

    -- Upsert: aynı theme_id varsa güncelle, yoksa ekle
    INSERT INTO presentation.themes (theme_id, config, custom_css)
    VALUES (p_theme_id, COALESCE(p_config, '{}'::JSONB), p_custom_css)
    ON CONFLICT (theme_id)
    DO UPDATE SET
        config     = COALESCE(EXCLUDED.config, presentation.themes.config),
        custom_css = COALESCE(EXCLUDED.custom_css, presentation.themes.custom_css),
        updated_at = NOW()
    RETURNING id INTO v_id;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION presentation.theme_upsert(INT, JSONB, TEXT) IS 'Upsert client theme configuration. theme_id references core catalog.themes (validated by backend before calling).';
