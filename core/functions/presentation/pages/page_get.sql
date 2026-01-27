-- ================================================================
-- PAGE_GET: Sayfa Detayı
-- Tablar ve contextler ile birlikte sayfa detayını döner.
-- ================================================================

DROP FUNCTION IF EXISTS presentation.page_get CASCADE;

CREATE OR REPLACE FUNCTION presentation.page_get(
    p_page_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_page JSONB;
BEGIN
    SELECT jsonb_build_object(
        'id', p.id,
        'code', p.code,
        'route', p.route,
        'title', lk.key,
        'permission', p.required_permission,
        'menuId', p.menu_id,
        'submenuId', p.submenu_id,
        'isActive', p.is_active,
        'createdAt', p.created_at,
        'updatedAt', p.updated_at,
        'tabs', '[]'::jsonb,
        'contexts', '[]'::jsonb
    )
    INTO v_page
    FROM presentation.pages p
    LEFT JOIN core.localization_keys lk ON lk.id = p.title_localization_key
    WHERE p.id = p_page_id
      AND p.is_active;

    IF v_page IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.page.not-found';
    END IF;

    RETURN v_page;
END;
$$;

COMMENT ON FUNCTION presentation.page_get IS 'Returns details of a page including tabs and contexts.';
