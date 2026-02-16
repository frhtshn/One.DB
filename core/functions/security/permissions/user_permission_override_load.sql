-- ================================================================
-- USER_PERMISSION_OVERRIDE_LOAD - Internal Override Yükleme
-- ================================================================
-- Kullanım: PermissionLoader tarafından kullanıcının kendi
-- override'larını yüklemek için. IDOR kontrolü YOK.
-- Bu fonksiyon sadece internal servisler tarafından çağrılmalı.
-- ================================================================

DROP FUNCTION IF EXISTS security.user_permission_override_load(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION security.user_permission_override_load(
    p_user_id BIGINT,
    p_tenant_id BIGINT DEFAULT NULL
)
RETURNS TABLE (
    permission_code VARCHAR(100),
    permission_name VARCHAR(150),
    category VARCHAR(50),
    is_granted BOOLEAN,
    tenant_id BIGINT,
    context_id BIGINT,
    reason VARCHAR(500),
    assigned_by BIGINT,
    assigned_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- User var mı kontrolü
    IF NOT EXISTS (SELECT 1 FROM security.users WHERE id = p_user_id AND status = 1) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
    END IF;

    RETURN QUERY
    SELECT
        p.code AS permission_code,
        p.name AS permission_name,
        p.category,
        up.is_granted,
        up.tenant_id,
        up.context_id,
        up.reason,
        up.assigned_by,
        up.assigned_at,
        up.expires_at
    FROM security.user_permission_overrides up
    JOIN security.permissions p ON up.permission_id = p.id
    WHERE up.user_id = p_user_id
      AND (p_tenant_id IS NULL OR up.tenant_id IS NULL OR up.tenant_id = p_tenant_id)
      AND (up.expires_at IS NULL OR up.expires_at > NOW())
    ORDER BY p.category, p.code;
END;
$$;

COMMENT ON FUNCTION security.user_permission_override_load IS
'Internal function for PermissionLoader. Loads user overrides without IDOR checks.
WARNING: Do not expose this to user-facing APIs.';