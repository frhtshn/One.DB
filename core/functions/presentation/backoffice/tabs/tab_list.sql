-- ================================================================
-- TAB_LIST: Sekme Listesi (Admin)
-- Belirli bir sayfaya ait tüm sekmeleri (aktif + pasif) listeler.
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
        'title', COALESCE(lk.localization_key, t.title_localization_key),
        'order', t.order_index,
        'permission', t.required_permission,
        'pageId', t.page_id,
        'isActive', t.is_active,
        'createdAt', t.created_at,
        'updatedAt', t.updated_at
    )), '[]'::jsonb)
    INTO v_items
    FROM presentation.tabs t
    LEFT JOIN catalog.localization_keys lk ON lk.localization_key = t.title_localization_key
    WHERE t.page_id = p_page_id;

    SELECT COUNT(1)
    INTO v_total_count
    FROM presentation.tabs t
    WHERE t.page_id = p_page_id;

    RETURN jsonb_build_object(
        'items', v_items,
        'totalCount', v_total_count
    );
END;
$$;

COMMENT ON FUNCTION presentation.tab_list IS 'Lists tabs for a given page, returns items and totalCount.';
