-- ================================================================
-- BUILD_PAGE_JSON - Page JSON'i olustur (tabs ve contexts dahil)
-- Helper function: get_structure tarafindan kullanilir
-- ================================================================

DROP FUNCTION IF EXISTS presentation.build_page_json(BIGINT);

CREATE OR REPLACE FUNCTION presentation.build_page_json(p_page_id BIGINT)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_page RECORD;
BEGIN
    -- Sayfa bilgilerini al
    SELECT * INTO v_page
    FROM presentation.pages
    WHERE id = p_page_id AND is_active = true;

    -- Sayfa bulunamadiysa bos obje don
    IF NOT FOUND THEN
        RETURN '{}'::JSONB;
    END IF;

    RETURN jsonb_build_object(
        'id', v_page.id,
        'code', v_page.code,
        'route', v_page.route,
        'title', v_page.title_localization_key,
        'permission', v_page.required_permission,
        'tabs', (
            SELECT COALESCE(jsonb_agg(
                jsonb_build_object(
                    'id', t.id,
                    'code', t.code,
                    'title', t.title_localization_key,
                    'order', t.order_index,
                    'permission', t.required_permission
                )
                ORDER BY t.order_index
            ), '[]'::JSONB)
            FROM presentation.tabs t
            WHERE t.page_id = p_page_id AND t.is_active = true
        ),
        'contexts', (
            SELECT COALESCE(jsonb_agg(
                jsonb_build_object(
                    'id', c.id,
                    'code', c.code,
                    'type', c.context_type,
                    'label', c.label_localization_key,
                    'permissionEdit', c.permission_edit,
                    'permissionReadonly', c.permission_readonly,
                    'permissionMask', c.permission_mask
                )
                ORDER BY c.id
            ), '[]'::JSONB)
            FROM presentation.contexts c
            WHERE c.page_id = p_page_id
        )
    );
END;
$$;

COMMENT ON FUNCTION presentation.build_page_json(BIGINT) IS 'Builds JSON object for a page (including tabs and contexts). Helper function for get_structure.';
