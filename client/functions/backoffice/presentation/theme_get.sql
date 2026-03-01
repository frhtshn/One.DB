-- ================================================================
-- THEME_GET: Aktif tema bilgisi getir (config dahil)
-- BO için detaylı tema bilgisi döner
-- ================================================================

DROP FUNCTION IF EXISTS presentation.theme_get(BIGINT);

CREATE OR REPLACE FUNCTION presentation.theme_get(
    p_id                BIGINT DEFAULT NULL  -- Theme kayıt ID (NULL = aktif tema)
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'id', t.id,
        'themeId', t.theme_id,
        'config', t.config,
        'customCss', t.custom_css,
        'isActive', t.is_active,
        'createdAt', t.created_at,
        'updatedAt', t.updated_at
    ) INTO v_result
    FROM presentation.themes t
    WHERE (p_id IS NOT NULL AND t.id = p_id)
       OR (p_id IS NULL AND t.is_active = TRUE)
    LIMIT 1;

    IF v_result IS NULL THEN
        RAISE EXCEPTION 'error.theme.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION presentation.theme_get(BIGINT) IS 'Get theme details. If no ID provided, returns the active theme.';
