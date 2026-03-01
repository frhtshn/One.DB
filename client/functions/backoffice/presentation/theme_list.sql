-- ================================================================
-- THEME_LIST: Client tema kayıtları listele
-- Tüm kayıtlı temaları döner (aktif + pasif)
-- ================================================================

DROP FUNCTION IF EXISTS presentation.theme_list();

CREATE OR REPLACE FUNCTION presentation.theme_list()
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'id', t.id,
        'themeId', t.theme_id,
        'config', t.config,
        'customCss', t.custom_css,
        'isActive', t.is_active,
        'createdAt', t.created_at,
        'updatedAt', t.updated_at
    ) ORDER BY t.is_active DESC, t.updated_at DESC), '[]'::JSONB)
    INTO v_result
    FROM presentation.themes t;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION presentation.theme_list() IS 'List all client theme records. Active theme listed first.';
