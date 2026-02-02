-- ================================================================
-- NUCLEO PLATFORM - PRODUCTION SEED FILE
-- ================================================================
-- Minimal production seed data.
-- Run: psql -U postgres -d nucleo -f core/data/production_seed.sql
-- ================================================================
-- CONTENTS:
-- 1. TRUNCATE (required tables only)
-- 2. Companies (platform only)
-- 3. Roles (with English descriptions)
-- 4. Permissions (with English descriptions)
-- 5. Role-Permission mapping
-- 6. Users (superadmin only)
-- 7. User roles (superadmin global role)
-- 8. Validation
-- ================================================================
-- WARNING: This file deletes ALL data and recreates it!
-- Use with caution in production environment.
-- ================================================================

-- ================================================================
-- 1. TRUNCATE REQUIRED TABLES
-- ================================================================

-- Security
TRUNCATE TABLE security.user_allowed_tenants RESTART IDENTITY CASCADE;
TRUNCATE TABLE security.user_roles RESTART IDENTITY CASCADE;
TRUNCATE TABLE security.users RESTART IDENTITY CASCADE;
TRUNCATE TABLE security.role_permissions RESTART IDENTITY CASCADE;
TRUNCATE TABLE security.permissions RESTART IDENTITY CASCADE;
TRUNCATE TABLE security.roles RESTART IDENTITY CASCADE;

-- Core
TRUNCATE TABLE core.tenant_settings RESTART IDENTITY CASCADE;
TRUNCATE TABLE core.tenant_languages RESTART IDENTITY CASCADE;
TRUNCATE TABLE core.tenant_currencies RESTART IDENTITY CASCADE;
TRUNCATE TABLE core.tenants RESTART IDENTITY CASCADE;
TRUNCATE TABLE core.companies RESTART IDENTITY CASCADE;

-- Sequence reset
SELECT setval('core.companies_id_seq', 1, false);

-- ================================================================
-- 2. COMPANIES
-- ================================================================

INSERT INTO core.companies (id, company_code, company_name, status, country_code, timezone) VALUES
(0, 'NUCLEO', 'Nucleo Platform', 1, 'TR', 'Europe/Istanbul');

SELECT setval('core.companies_id_seq', (SELECT MAX(id) FROM core.companies) + 1);

-- ================================================================
-- 3. ROLES
-- ================================================================
-- Hierarchy: superadmin > admin > companyadmin > tenantadmin > moderator > editor > operator > user

INSERT INTO security.roles (code, name, description, level, status, is_platform_role) VALUES
('superadmin', 'Super Admin', 'Platform owner - Full access to all features', 100, 1, TRUE),
('admin', 'Admin', 'System administrator - All company and tenant operations', 90, 1, TRUE),
('companyadmin', 'Company Admin', 'Company manager - Tenant operations under own company', 80, 1, FALSE),
('tenantadmin', 'Tenant Admin', 'Tenant manager - Operations within own tenant', 70, 1, FALSE),
('moderator', 'Moderator', 'Content moderator - Player editing permissions', 60, 1, FALSE),
('editor', 'Editor', 'Content editor - Banner, slider, content management', 50, 1, FALSE),
('operator', 'Operator', 'Customer service - Player viewing and KYC', 40, 1, FALSE),
('user', 'User', 'Standard user - View only access', 10, 1, FALSE);

-- ================================================================
-- 4. PERMISSIONS
-- ================================================================
-- Scope-based permission structure:
-- - platform.*  → SuperAdmin only
-- - company.*   → Admin + SuperAdmin
-- - tenant.*    → CompanyAdmin + Admin + SuperAdmin
-- - audit.*     → TenantAdmin and above

INSERT INTO security.permissions (code, name, description, category, status) VALUES
-- PLATFORM SCOPE (6) - SuperAdmin only
('platform.menu.manage', 'Menu Management', 'Menu/Submenu/Page/Tab/Context CRUD operations', 'platform', 1),
('platform.permission.manage', 'Permission Management', 'Define and edit permissions', 'platform', 1),
('platform.role.manage', 'Role Management', 'Define and edit roles', 'platform', 1),
('platform.system.settings', 'System Settings', 'Platform settings management', 'platform', 1),
('platform.logs.view', 'View Logs', 'View system logs', 'platform', 1),
('platform.health.view', 'Health Check', 'System health monitoring', 'platform', 1),

-- COMPANY SCOPE (10) - Admin + SuperAdmin
('company.list', 'Company List', 'List all companies', 'company', 1),
('company.view', 'View Company', 'View company details', 'company', 1),
('company.create', 'Create Company', 'Create new company', 'company', 1),
('company.edit', 'Edit Company', 'Edit company information', 'company', 1),
('company.delete', 'Delete Company', 'Delete company (soft delete)', 'company', 1),
('company.user.list', 'Company User List', 'List company users', 'company', 1),
('company.user.create', 'Create Company User', 'Add user to company', 'company', 1),
('company.user.edit', 'Edit Company User', 'Edit company user', 'company', 1),
('company.tenant.create', 'Create Tenant', 'Create new tenant', 'company', 1),
('company.tenant.edit', 'Edit Tenant', 'Edit tenant information', 'company', 1),

-- TENANT SCOPE (8) - CompanyAdmin + Admin + SuperAdmin
('tenant.list', 'Tenant List', 'List tenants (own company)', 'tenant', 1),
('tenant.view', 'View Tenant', 'View tenant details', 'tenant', 1),
('tenant.edit', 'Edit Tenant', 'Edit tenant information (limited)', 'tenant', 1),
('tenant.user.list', 'Tenant User List', 'List tenant users', 'tenant', 1),
('tenant.user.create', 'Create Tenant User', 'Add user to tenant', 'tenant', 1),
('tenant.user.role.assign', 'Assign Tenant Role', 'Assign tenant role to user', 'tenant', 1),
('tenant.user.delete', 'Delete Tenant User', 'Delete tenant user (soft delete)', 'tenant', 1),
('tenant.user.edit', 'Edit Tenant User', 'Edit tenant user (including password reset)', 'tenant', 1),

-- TENANT INTERNAL SCOPE (3) - TenantAdmin and above
('tenant.user.permission.grant', 'Grant Permission', 'Grant permission override to user', 'tenant', 1),
('tenant.user.permission.deny', 'Deny Permission', 'Deny permission override from user', 'tenant', 1),
('tenant.settings.edit', 'Tenant Settings', 'Edit tenant settings', 'tenant', 1),

-- AUDIT SCOPE (3) - TenantAdmin and above
('audit.list', 'Audit Log List', 'List audit logs', 'audit', 1),
('audit.view', 'View Audit Log', 'View audit log details', 'audit', 1),
('audit.export', 'Export Audit Log', 'Export audit logs', 'audit', 1);

-- ================================================================
-- 5. ROLE-PERMISSION MAPPING
-- ================================================================

-- SUPERADMIN: ALL PERMISSIONS
INSERT INTO security.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM security.roles r
CROSS JOIN security.permissions p
WHERE r.code = 'superadmin';

-- ADMIN: company.* + tenant.* + audit.* (excluding platform.*)
INSERT INTO security.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM security.roles r
CROSS JOIN security.permissions p
WHERE r.code = 'admin'
  AND p.category IN ('company', 'tenant', 'audit');

-- COMPANYADMIN: tenant.* + audit.* (excluding company.*)
INSERT INTO security.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM security.roles r
CROSS JOIN security.permissions p
WHERE r.code = 'companyadmin'
  AND p.category IN ('tenant', 'audit');

-- TENANTADMIN: tenant.user.* + tenant.settings.* + tenant.user.permission.* + audit.*
-- NOTE: No tenant.view/list - TenantAdmin works within their own tenant
INSERT INTO security.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM security.roles r
CROSS JOIN security.permissions p
WHERE r.code = 'tenantadmin'
  AND (
    p.code IN (
      'tenant.user.list',
      'tenant.user.create',
      'tenant.user.edit',
      'tenant.user.delete',
      'tenant.user.role.assign',
      'tenant.user.permission.grant',
      'tenant.user.permission.deny',
      'tenant.settings.edit'
    )
    OR p.category = 'audit'
  );

-- MODERATOR: tenant.user.list + audit.list + audit.view
INSERT INTO security.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM security.roles r
CROSS JOIN security.permissions p
WHERE r.code = 'moderator'
  AND p.code IN ('tenant.user.list', 'audit.list', 'audit.view');

-- EDITOR: audit.list
INSERT INTO security.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM security.roles r
CROSS JOIN security.permissions p
WHERE r.code = 'editor'
  AND p.code IN ('audit.list');

-- OPERATOR: tenant.user.list + audit.list
INSERT INTO security.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM security.roles r
CROSS JOIN security.permissions p
WHERE r.code = 'operator'
  AND p.code IN ('tenant.user.list', 'audit.list');

-- USER: audit.list (minimum permission)
INSERT INTO security.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM security.roles r
CROSS JOIN security.permissions p
WHERE r.code = 'user'
  AND p.code IN ('audit.list');

-- ================================================================
-- 6. USERS
-- ================================================================
-- Password: deneme
-- Hash: zsECiTmx0nxGD5ymsfm0Lw==:YYJDTEdcIwrDmFRqT8fqJ59Fzw81zTKcE1fHBSs9gwo=
-- WARNING: Change this password immediately after first login!

INSERT INTO security.users (company_id, first_name, last_name, email, username, password, status, language, timezone, currency) VALUES
(0, 'Super', 'Admin', 'superadmin@nucleo.io', 'superadmin',
 'zsECiTmx0nxGD5ymsfm0Lw==:YYJDTEdcIwrDmFRqT8fqJ59Fzw81zTKcE1fHBSs9gwo=',
 1, 'en', 'Europe/Istanbul', 'EUR');

-- ================================================================
-- 7. GLOBAL ROLE ASSIGNMENT
-- ================================================================

-- superadmin@nucleo.io → superadmin (global)
INSERT INTO security.user_roles (user_id, role_id, tenant_id)
SELECT u.id, r.id, NULL FROM security.users u, security.roles r
WHERE u.email = 'superadmin@nucleo.io' AND r.code = 'superadmin';

-- ================================================================
-- 8. VALIDATION
-- ================================================================

DO $$
DECLARE
    v_companies INT;
    v_roles INT;
    v_permissions INT;
    v_role_permissions INT;
    v_users INT;
    v_user_roles INT;
BEGIN
    SELECT COUNT(*) INTO v_companies FROM core.companies;
    SELECT COUNT(*) INTO v_roles FROM security.roles;
    SELECT COUNT(*) INTO v_permissions FROM security.permissions;
    SELECT COUNT(*) INTO v_role_permissions FROM security.role_permissions;
    SELECT COUNT(*) INTO v_users FROM security.users;
    SELECT COUNT(*) INTO v_user_roles FROM security.user_roles;

    RAISE NOTICE '================================================';
    RAISE NOTICE 'NUCLEO PLATFORM PRODUCTION SEED COMPLETED';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Companies: %', v_companies;
    RAISE NOTICE 'Roles: %', v_roles;
    RAISE NOTICE 'Permissions: %', v_permissions;
    RAISE NOTICE 'Role-Permission Mappings: %', v_role_permissions;
    RAISE NOTICE 'Users: %', v_users;
    RAISE NOTICE 'User Role Assignments: %', v_user_roles;
    RAISE NOTICE '================================================';
    RAISE NOTICE 'WARNING: Change superadmin password immediately!';
    RAISE NOTICE '================================================';
END $$;

-- Role-Permission summary
SELECT r.code as role, COUNT(rp.permission_id) as permission_count
FROM security.roles r
LEFT JOIN security.role_permissions rp ON r.id = rp.role_id
GROUP BY r.code, r.id
ORDER BY CASE r.code
    WHEN 'superadmin' THEN 1 WHEN 'admin' THEN 2 WHEN 'companyadmin' THEN 3
    WHEN 'tenantadmin' THEN 4 WHEN 'moderator' THEN 5 WHEN 'editor' THEN 6
    WHEN 'operator' THEN 7 WHEN 'user' THEN 8
END;

-- ================================================================
-- PRODUCTION USER SUMMARY
-- ================================================================
--
-- | Email                | Company | Role       |
-- |----------------------|---------|------------|
-- | superadmin@nucleo.io | NUCLEO  | superadmin |
--
-- Default password: deneme (MUST BE CHANGED!)
-- ================================================================
