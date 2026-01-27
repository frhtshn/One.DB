-- ================================================================
-- TAB_LIST: Sekmeleri listeler (pageId filtreli)
-- ================================================================

DROP FUNCTION IF EXISTS presentation.tab_list CASCADE;
CREATE OR REPLACE FUNCTION presentation.tab_list(
    p_page_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_items JSONB;
    v_total_count INT;
BEGIN
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'id', t.id,
        'code', t.code,
        'title', lk.key,
        'order', t.order_index,
        'permission', t.required_permission,
        'pageId', t.page_id,
        'isActive', t.is_active,
        'createdAt', t.created_at,
        'updatedAt', t.updated_at
    )), '[]'::jsonb)
    INTO v_items
    FROM presentation.tabs t
    LEFT JOIN core.localization_keys lk ON lk.id = t.title_localization_key
    WHERE t.page_id = p_page_id
      AND t.is_active;

    SELECT COUNT(1)
    INTO v_total_count
    FROM presentation.tabs t
    WHERE t.page_id = p_page_id
      AND t.is_active;

    RETURN jsonb_build_object(
        'items', v_items,
        'totalCount', v_total_count
    );
END;
$$;

COMMENT ON FUNCTION presentation.tab_list IS 'Lists tabs for a given page, returns items and totalCount.';
