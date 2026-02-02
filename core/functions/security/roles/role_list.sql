-- =============================================
-- 1. ROLE_LIST: Sayfalamali rol listesi
-- Returns: JSONB {items, totalCount} - success wrapper YOK
-- Birleşik user_roles: tenant_id IS NULL = global, tenant_id IS NOT NULL = tenant
-- =============================================

DROP FUNCTION IF EXISTS security.role_list(INT, INT, VARCHAR, SMALLINT);

CREATE OR REPLACE FUNCTION security.role_list(
    p_page INT DEFAULT 1,
    p_page_size INT DEFAULT 20,
    p_search VARCHAR DEFAULT NULL,
    p_status SMALLINT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_offset INT;
    v_total_count INT;
    v_items JSONB;
    v_search_pattern VARCHAR;
BEGIN
    v_offset := (p_page - 1) * p_page_size;
    v_search_pattern := CASE WHEN p_search IS NOT NULL THEN '%' || LOWER(p_search) || '%' ELSE NULL END;

    -- Total count
    SELECT COUNT(*)
    INTO v_total_count
    FROM security.roles r
    WHERE (p_status IS NULL OR r.status = p_status)
      AND (v_search_pattern IS NULL OR
           LOWER(r.code) LIKE v_search_pattern OR
           LOWER(r.name) LIKE v_search_pattern);

    -- Items with optimized JOIN (birleşik user_roles)
    WITH role_stats AS (
        SELECT
            r.id AS role_id,
            COUNT(DISTINCT CASE WHEN ur.tenant_id IS NULL THEN ur.user_id END) AS global_user_count,
            COUNT(DISTINCT CASE WHEN ur.tenant_id IS NOT NULL THEN ur.user_id END) AS tenant_user_count,
            COUNT(DISTINCT rp.permission_id) AS permission_count
        FROM security.roles r
        LEFT JOIN security.user_roles ur ON ur.role_id = r.id
        LEFT JOIN security.role_permissions rp ON rp.role_id = r.id
        WHERE (p_status IS NULL OR r.status = p_status)
          AND (v_search_pattern IS NULL OR
               LOWER(r.code) LIKE v_search_pattern OR
               LOWER(r.name) LIKE v_search_pattern)
        GROUP BY r.id
    )
    SELECT COALESCE(jsonb_agg(to_jsonb(t) ORDER BY t."createdAt" DESC), '[]'::jsonb)
    INTO v_items
    FROM (
        SELECT
            r.id,
            r.code,
            r.name,
            r.description,
            r.status,
            r.created_at AS "createdAt",
            r.updated_at AS "updatedAt",
            COALESCE(rs.global_user_count, 0) + COALESCE(rs.tenant_user_count, 0) AS "userCount",
            COALESCE(rs.permission_count, 0) AS "permissionCount"
        FROM security.roles r
        LEFT JOIN role_stats rs ON rs.role_id = r.id
        WHERE (p_status IS NULL OR r.status = p_status)
          AND (v_search_pattern IS NULL OR
               LOWER(r.code) LIKE v_search_pattern OR
               LOWER(r.name) LIKE v_search_pattern)
        ORDER BY r.created_at DESC
        LIMIT p_page_size
        OFFSET v_offset
    ) t;

    -- Permission pattern: dogrudan {items, totalCount} don
    RETURN jsonb_build_object(
        'items', v_items,
        'totalCount', v_total_count
    );
END;
$$;

COMMENT ON FUNCTION security.role_list IS 'Paginated role list with user/permission counts. Returns items + totalCount. Uses unified user_roles table.';
