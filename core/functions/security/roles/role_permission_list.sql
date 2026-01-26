-- =============================================
-- 7. ROLE_PERMISSION_LIST: Rol permission listesi
-- Returns: JSONB array - dogrudan permission listesi
-- =============================================

DROP FUNCTION IF EXISTS security.role_permission_list(BIGINT);

CREATE OR REPLACE FUNCTION security.role_permission_list(
    p_role_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_role_exists BOOLEAN;
    v_permissions JSONB;
BEGIN
    SELECT EXISTS(SELECT 1 FROM security.roles WHERE id = p_role_id)
    INTO v_role_exists;

    IF NOT v_role_exists THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.role.not-found';
    END IF;

    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'id', p.id,
        'code', p.code,
        'name', p.name,
        'description', p.description,
        'category', p.category
    ) ORDER BY p.category, p.code), '[]'::jsonb)
    INTO v_permissions
    FROM security.role_permissions rp
    JOIN security.permissions p ON p.id = rp.permission_id
    WHERE rp.role_id = p_role_id AND p.status = 1;

    -- Dogrudan array don
    RETURN v_permissions;
END;
$$;

COMMENT ON FUNCTION security.role_permission_list IS 'Lists permissions for a role.';
