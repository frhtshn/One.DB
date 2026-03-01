-- ================================================================
-- LAYOUT_LIST: Yerleşim listesi
-- Tüm layout kayıtlarını döner
-- ================================================================

DROP FUNCTION IF EXISTS presentation.layout_list();

CREATE OR REPLACE FUNCTION presentation.layout_list()
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'id', l.id,
        'layoutName', l.layout_name,
        'pageId', l.page_id,
        'structure', l.structure,
        'isActive', l.is_active,
        'createdAt', l.created_at,
        'updatedAt', l.updated_at
    ) ORDER BY l.layout_name, l.page_id NULLS FIRST), '[]'::JSONB)
    INTO v_result
    FROM presentation.layouts l;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION presentation.layout_list() IS 'List all page layouts ordered by name. Global layouts (page_id=NULL) listed first.';
