-- ================================================================
-- CANNED_RESPONSE_LIST: Hazır yanıtları listele
-- ================================================================
-- Aktif hazır yanıt şablonlarını listeler.
-- Opsiyonel kategori ve arama filtresi.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.canned_response_list(BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION support.canned_response_list(
    p_category_id   BIGINT DEFAULT NULL,
    p_search        VARCHAR(100) DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_items JSONB;
BEGIN
    SELECT COALESCE(jsonb_agg(sub.item ORDER BY sub.sort_title), '[]'::JSONB)
    INTO v_items
    FROM (
        SELECT jsonb_build_object(
            'id', cr.id,
            'title', cr.title,
            'content', cr.content,
            'categoryId', cr.category_id,
            'categoryName', tc.name,
            'createdBy', cr.created_by,
            'createdAt', cr.created_at,
            'updatedAt', cr.updated_at
        ) AS item,
        cr.title AS sort_title
        FROM support.canned_responses cr
        LEFT JOIN support.ticket_categories tc ON tc.id = cr.category_id AND tc.is_active = true
        WHERE cr.is_active = true
          AND (p_category_id IS NULL OR cr.category_id = p_category_id)
          AND (p_search IS NULL OR cr.title ILIKE '%' || p_search || '%')
    ) sub;

    RETURN jsonb_build_object('items', v_items);
END;
$$;

COMMENT ON FUNCTION support.canned_response_list IS 'Lists active canned response templates with optional category and search filters.';
