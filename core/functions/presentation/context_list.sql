-- ================================================================
-- CONTEXT_LIST: Contextleri listeler (pageId filtreli)
-- ================================================================

DROP FUNCTION IF EXISTS presentation.context_list CASCADE;
CREATE OR REPLACE FUNCTION presentation.context_list(
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
        'id', c.id,
        'pageId', c.page_id,
        'code', c.code,
        'type', c.context_type,
        'label', c.label_localization_key,
        'permissionEdit', c.permission_edit,
        'permissionReadonly', c.permission_readonly,
        'permissionMask', c.permission_mask,
        'createdAt', c.created_at,
        'updatedAt', c.updated_at
    )), '[]'::jsonb)
    INTO v_items
    FROM presentation.contexts c
    WHERE c.page_id = p_page_id;

    SELECT COUNT(1)
    INTO v_total_count
    FROM presentation.contexts c
    WHERE c.page_id = p_page_id;

    RETURN jsonb_build_object(
        'items', v_items,
        'totalCount', v_total_count
    );
END;
$$;

COMMENT ON FUNCTION presentation.context_list IS 'Lists contexts for a given page, returns items and totalCount.';
