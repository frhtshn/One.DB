-- =============================================
-- 2. ROLE_GET: Code ile rol detayi
-- Returns: JSONB - dogrudan rol verisi (success wrapper YOK)
-- Birleşik user_roles: tenant_id IS NULL = global, tenant_id IS NOT NULL = tenant
-- =============================================

DROP FUNCTION IF EXISTS security.role_get(VARCHAR);

CREATE OR REPLACE FUNCTION security.role_get(
    p_code VARCHAR
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_role JSONB;
    v_role_id BIGINT;
BEGIN
    -- Once role_id al
    SELECT id INTO v_role_id FROM security.roles WHERE code = LOWER(p_code);

    IF v_role_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.role.not-found';
    END IF;

    -- Tek sorguda tum bilgileri al (birleşik user_roles)
    WITH role_stats AS (
        SELECT
            COUNT(DISTINCT CASE WHEN ur.tenant_id IS NULL THEN ur.user_id END) AS global_user_count,
            COUNT(DISTINCT CASE WHEN ur.tenant_id IS NOT NULL THEN ur.user_id END) AS tenant_user_count,
            COUNT(DISTINCT rp.permission_id) AS permission_count
        FROM security.roles r
        LEFT JOIN security.user_roles ur ON ur.role_id = r.id
        LEFT JOIN security.role_permissions rp ON rp.role_id = r.id
        WHERE r.id = v_role_id
    ),
    role_permissions AS (
        SELECT COALESCE(jsonb_agg(jsonb_build_object(
            'code', p.code,
            'name', p.name,
            'category', p.category
        ) ORDER BY p.category, p.code), '[]'::jsonb) AS permissions
        FROM security.role_permissions rp
        JOIN security.permissions p ON p.id = rp.permission_id
        WHERE rp.role_id = v_role_id AND p.status = 1
    )
    SELECT jsonb_build_object(
        'id', r.id,
        'code', r.code,
        'name', r.name,
        'description', r.description,
        'status', r.status,
        'createdAt', r.created_at,
        'updatedAt', r.updated_at,
        'userCount', COALESCE(rs.global_user_count, 0) + COALESCE(rs.tenant_user_count, 0),
        'permissionCount', COALESCE(rs.permission_count, 0),
        'permissions', rp.permissions
    )
    INTO v_role
    FROM security.roles r
    CROSS JOIN role_stats rs
    CROSS JOIN role_permissions rp
    WHERE r.id = v_role_id;

    -- Permission pattern: dogrudan data don
    RETURN v_role;
END;
$$;

COMMENT ON FUNCTION security.role_get IS 'Get role details by code, including permissions. Uses unified user_roles table.';
