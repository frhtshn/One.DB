-- ================================================================
-- PERMISSION_LIST: Sayfalamali permission listesi
-- Filtreler: category, search (code/name), status
-- Tek seferde items + totalCount doner
-- ================================================================

DROP FUNCTION IF EXISTS security.permission_list(INT, INT, VARCHAR, VARCHAR, SMALLINT);

CREATE OR REPLACE FUNCTION security.permission_list(
    p_page INT DEFAULT 1,
    p_page_size INT DEFAULT 20,
    p_category VARCHAR(50) DEFAULT NULL,
    p_search VARCHAR(100) DEFAULT NULL,
    p_status SMALLINT DEFAULT 1
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_offset INT;
    v_items JSONB;
    v_total_count BIGINT;
BEGIN
    v_offset := (p_page - 1) * p_page_size;

    -- Total count'u ayri hesapla
    SELECT COUNT(*)
    INTO v_total_count
    FROM security.permissions p
    WHERE (p_category IS NULL OR p.category = p_category)
      AND (p_status IS NULL OR p.status = p_status)
      AND (p_search IS NULL OR p.code ILIKE '%' || p_search || '%' OR p.name ILIKE '%' || p_search || '%');

    -- Sayfalanmis items
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', p.id,
            'code', p.code,
            'name', p.name,
            'description', p.description,
            'category', p.category,
            'status', p.status,
            'createdAt', p.created_at,
            'updatedAt', p.updated_at
        ) ORDER BY p.category, p.code
    ), '[]'::jsonb)
    INTO v_items
    FROM (
        SELECT *
        FROM security.permissions p
        WHERE (p_category IS NULL OR p.category = p_category)
          AND (p_status IS NULL OR p.status = p_status)
          AND (p_search IS NULL OR p.code ILIKE '%' || p_search || '%' OR p.name ILIKE '%' || p_search || '%')
        ORDER BY p.category, p.code
        LIMIT p_page_size OFFSET v_offset
    ) p;

    RETURN jsonb_build_object(
        'items', v_items,
        'totalCount', v_total_count
    );
END;
$$;

COMMENT ON FUNCTION security.permission_list IS 'Paginated permissions list. Returns items + totalCount.';
