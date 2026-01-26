-- ================================================================
-- PERMISSION_GET: Code ile permission detayi
-- ================================================================

DROP FUNCTION IF EXISTS security.permission_get(VARCHAR);

CREATE OR REPLACE FUNCTION security.permission_get(
    p_code VARCHAR(100)
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_permission RECORD;
    v_role_count INT;
BEGIN
    -- Permission'i bul
    SELECT id, code, name, description, category, status, created_at, updated_at
    INTO v_permission
    FROM security.permissions
    WHERE code = LOWER(TRIM(p_code));

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.permission.not-found';
    END IF;

    -- Bu permission'a sahip rol sayisini hesapla
    SELECT COUNT(DISTINCT rp.role_id)
    INTO v_role_count
    FROM security.role_permissions rp
    WHERE rp.permission_id = v_permission.id;

    RETURN jsonb_build_object(
        'id', v_permission.id,
        'code', v_permission.code,
        'name', v_permission.name,
        'description', v_permission.description,
        'category', v_permission.category,
        'status', v_permission.status,
        'createdAt', v_permission.created_at,
        'updatedAt', v_permission.updated_at,
        'roleCount', v_role_count
    );
END;
$$;

COMMENT ON FUNCTION security.permission_get IS 'Get permission details by code, including role count.';
