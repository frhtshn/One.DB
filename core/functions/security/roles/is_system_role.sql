-- =============================================
-- HELPER: Sistem rol kontrolu (DRY)
-- =============================================

DROP FUNCTION IF EXISTS security.is_system_role(VARCHAR);

CREATE OR REPLACE FUNCTION security.is_system_role(p_role_code VARCHAR)
RETURNS BOOLEAN
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
    RETURN LOWER(p_role_code) IN ('superadmin', 'company_admin');
END;
$$;

COMMENT ON FUNCTION security.is_system_role IS 'Checks if a role code is a protected system role (e.g. superadmin).';
