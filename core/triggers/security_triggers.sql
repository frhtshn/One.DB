-- ============================================================================
-- SECURITY TRIGGERS
-- ============================================================================

-- Users
DROP TRIGGER IF EXISTS trigger_users_updated_at ON security.users;
CREATE TRIGGER trigger_users_updated_at
    BEFORE UPDATE ON security.users
    FOR EACH ROW EXECUTE FUNCTION core.update_updated_at_column();

-- Roles
DROP TRIGGER IF EXISTS trigger_roles_updated_at ON security.roles;
CREATE TRIGGER trigger_roles_updated_at
    BEFORE UPDATE ON security.roles
    FOR EACH ROW EXECUTE FUNCTION core.update_updated_at_column();

-- Permissions
DROP TRIGGER IF EXISTS trigger_permissions_updated_at ON security.permissions;
CREATE TRIGGER trigger_permissions_updated_at
    BEFORE UPDATE ON security.permissions
    FOR EACH ROW EXECUTE FUNCTION core.update_updated_at_column();
