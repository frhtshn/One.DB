-- ================================================================
-- USER_PERMISSION_SET - Permission Grant/Deny
-- ================================================================

DROP FUNCTION IF EXISTS security.user_permission_set(BIGINT, VARCHAR, BOOLEAN, BIGINT, VARCHAR, BIGINT, TIMESTAMPTZ);

CREATE OR REPLACE FUNCTION security.user_permission_set(
    p_user_id BIGINT,
    p_permission_code VARCHAR(100),
    p_is_granted BOOLEAN,
    p_tenant_id BIGINT DEFAULT NULL,
    p_reason VARCHAR(500) DEFAULT NULL,
    p_assigned_by BIGINT DEFAULT NULL,
    p_expires_at TIMESTAMPTZ DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_permission_id BIGINT;
    v_existing_id BIGINT;
BEGIN
    -- Permission code'u ID'ye çevir
    SELECT id INTO v_permission_id
    FROM security.permissions
    WHERE code = p_permission_code AND status = 1;

    IF v_permission_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.permission.not-found';
    END IF;

    -- User var mı kontrol
    IF NOT EXISTS (SELECT 1 FROM security.users WHERE id = p_user_id AND status = 1) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
    END IF;

    -- Mevcut override var mı?
    SELECT id INTO v_existing_id
    FROM security.user_permission_overrides
    WHERE user_id = p_user_id
      AND permission_id = v_permission_id
      AND COALESCE(tenant_id, -1) = COALESCE(p_tenant_id, -1);

    IF v_existing_id IS NOT NULL THEN
        -- Güncelle
        UPDATE security.user_permission_overrides
        SET is_granted = p_is_granted,
            reason = COALESCE(p_reason, reason),
            assigned_by = COALESCE(p_assigned_by, assigned_by),
            assigned_at = NOW(),
            expires_at = p_expires_at
        WHERE id = v_existing_id;

        RETURN jsonb_build_object(
            'action', 'updated',
            'id', v_existing_id,
            'permissionCode', p_permission_code,
            'isGranted', p_is_granted
        );
    ELSE
        -- Yeni kayıt
        INSERT INTO security.user_permission_overrides (
            user_id, permission_id, tenant_id, is_granted,
            reason, assigned_by, expires_at
        ) VALUES (
            p_user_id, v_permission_id, p_tenant_id, p_is_granted,
            p_reason, p_assigned_by, p_expires_at
        )
        RETURNING id INTO v_existing_id;

        RETURN jsonb_build_object(
            'action', 'created',
            'id', v_existing_id,
            'permissionCode', p_permission_code,
            'isGranted', p_is_granted
        );
    END IF;
END;
$$;

COMMENT ON FUNCTION security.user_permission_set IS 'Grants or Denies a specific permission to a user. Creates or updates an override.';
