-- ================================================================
-- PERMISSION_EXISTS - Permission Code Geçerli mi?
-- ================================================================

DROP FUNCTION IF EXISTS security.permission_exists(VARCHAR);

CREATE OR REPLACE FUNCTION security.permission_exists(
    p_permission_code VARCHAR(100)
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM security.permissions
        WHERE code = p_permission_code AND status = 1
    );
END;
$$;

COMMENT ON FUNCTION security.permission_exists IS 'Checks if a permission code exists and is active';
