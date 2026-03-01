-- ================================================================
-- PUBLIC_THEME_GET: Frontend aktif tema getir
-- Parametresiz — aktif temayı döner
-- Frontend theme_id ile catalog'dan default_config alıp merge eder
-- ================================================================

DROP FUNCTION IF EXISTS presentation.public_theme_get();

CREATE OR REPLACE FUNCTION presentation.public_theme_get()
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'themeId', t.theme_id,
        'config', t.config,
        'customCss', t.custom_css
    ) INTO v_result
    FROM presentation.themes t
    WHERE t.is_active = TRUE
    LIMIT 1;

    -- Tema yoksa boş config döner (FE default kullanır)
    IF v_result IS NULL THEN
        RETURN jsonb_build_object(
            'themeId', NULL,
            'config', '{}'::JSONB,
            'customCss', NULL
        );
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION presentation.public_theme_get() IS 'Get active theme configuration for frontend rendering. Returns empty config if no theme is set.';
