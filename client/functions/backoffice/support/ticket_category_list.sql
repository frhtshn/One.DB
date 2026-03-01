-- ================================================================
-- TICKET_CATEGORY_LIST: Ticket kategori listesi (hiyerarşik)
-- ================================================================
-- Aktif kategorileri hiyerarşik ağaç yapısında döner.
-- p_language ile JSONB name'den istenen dil seçilir.
-- Recursive CTE ile parent-child ilişkisi çözülür.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.ticket_category_list(VARCHAR);

CREATE OR REPLACE FUNCTION support.ticket_category_list(
    p_language VARCHAR(10) DEFAULT 'tr'
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result    JSONB;
BEGIN
    -- Hiyerarşik ağaç oluştur
    WITH RECURSIVE category_tree AS (
        -- Kök kategoriler (parent_id IS NULL)
        SELECT
            id,
            parent_id,
            code,
            name,
            description,
            display_order,
            0 AS depth
        FROM support.ticket_categories
        WHERE parent_id IS NULL AND is_active = true

        UNION ALL

        -- Alt kategoriler
        SELECT
            c.id,
            c.parent_id,
            c.code,
            c.name,
            c.description,
            c.display_order,
            ct.depth + 1
        FROM support.ticket_categories c
        INNER JOIN category_tree ct ON c.parent_id = ct.id
        WHERE c.is_active = true
    ),
    -- Alt kategorileri JSON dizisi olarak grupla (en derin seviyeden başla)
    children_agg AS (
        SELECT
            ct.parent_id,
            jsonb_agg(
                jsonb_build_object(
                    'id', ct.id,
                    'code', ct.code,
                    'name', COALESCE(ct.name ->> p_language, ct.name ->> 'en', ct.code),
                    'description', CASE WHEN ct.description IS NOT NULL THEN COALESCE(ct.description ->> p_language, ct.description ->> 'en') ELSE NULL END,
                    'displayOrder', ct.display_order,
                    'children', COALESCE(ca_inner.children, '[]'::JSONB)
                )
                ORDER BY ct.display_order, ct.code
            ) AS children
        FROM category_tree ct
        LEFT JOIN LATERAL (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'id', sub.id,
                    'code', sub.code,
                    'name', COALESCE(sub.name ->> p_language, sub.name ->> 'en', sub.code),
                    'description', CASE WHEN sub.description IS NOT NULL THEN COALESCE(sub.description ->> p_language, sub.description ->> 'en') ELSE NULL END,
                    'displayOrder', sub.display_order,
                    'children', '[]'::JSONB
                )
                ORDER BY sub.display_order, sub.code
            ) AS children
            FROM category_tree sub
            WHERE sub.parent_id = ct.id
        ) ca_inner ON true
        WHERE ct.parent_id IS NOT NULL
        GROUP BY ct.parent_id
    )
    -- Kök kategorileri son çıktı olarak al
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', root.id,
            'code', root.code,
            'name', COALESCE(root.name ->> p_language, root.name ->> 'en', root.code),
            'description', CASE WHEN root.description IS NOT NULL THEN COALESCE(root.description ->> p_language, root.description ->> 'en') ELSE NULL END,
            'displayOrder', root.display_order,
            'children', COALESCE(ca.children, '[]'::JSONB)
        )
        ORDER BY root.display_order, root.code
    ), '[]'::JSONB)
    INTO v_result
    FROM category_tree root
    LEFT JOIN children_agg ca ON ca.parent_id = root.id
    WHERE root.parent_id IS NULL;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION support.ticket_category_list IS 'Lists active ticket categories as a hierarchical tree structure. Language parameter selects localized names from JSONB.';
