-- ================================================================
-- SORTIS ONE - PRODUCTION SEED FILE
-- ================================================================
-- Minimal production seed data.
-- ================================================================
-- ÇALIŞTIRMA:
--   psql -f core/data/production_seed.sql       (bu dosya)
--   psql -f core/data/permissions_full.sql      (permissions - UPSERT)
--   psql -f core/data/role_permissions_full.sql (role mapping - UPSERT)
-- NOT: UPSERT kullanıldığı için sıralama esnek, ancak önerilen sıra yukarıdaki.
-- ================================================================
-- CONTENTS:
-- 1. TRUNCATE (users, roles, companies - NOT permissions)
-- 2. Companies (platform only)
-- 3. Roles (with English descriptions)
-- 4. Users (superadmin only)
-- 5. User roles (superadmin global role)
-- 6. Validation
-- NOTE: Permissions managed separately in permissions_full.sql
-- ================================================================
-- WARNING: This file deletes user/role/company data!
-- Permissions are managed in permissions_full.sql
-- ================================================================

-- ================================================================
-- 1. TRUNCATE REQUIRED TABLES
-- ================================================================
-- NOT: permissions ve role_permissions TRUNCATE edilmiyor
-- Bunlar permissions_full.sql ve role_permissions_full.sql'de yönetiliyor

-- Security (users & roles only)
TRUNCATE TABLE security.user_allowed_clients RESTART IDENTITY CASCADE;
TRUNCATE TABLE security.user_roles RESTART IDENTITY CASCADE;
TRUNCATE TABLE security.users RESTART IDENTITY CASCADE;
TRUNCATE TABLE security.roles RESTART IDENTITY CASCADE;

-- Core
TRUNCATE TABLE core.client_settings RESTART IDENTITY CASCADE;
TRUNCATE TABLE core.client_languages RESTART IDENTITY CASCADE;
TRUNCATE TABLE core.client_currencies RESTART IDENTITY CASCADE;
TRUNCATE TABLE core.clients RESTART IDENTITY CASCADE;
TRUNCATE TABLE core.companies RESTART IDENTITY CASCADE;

-- Sequence reset
SELECT setval('core.companies_id_seq', 1, false);

-- ================================================================
-- 2. COMPANIES
-- ================================================================

INSERT INTO core.companies (id, company_code, company_name, status, country_code, timezone) VALUES
(0, 'SORTIS', 'Sortis One Platform', 1, 'TR', 'Europe/Istanbul');

SELECT setval('core.companies_id_seq', (SELECT MAX(id) FROM core.companies) + 1);

-- ================================================================
-- 3. ROLES
-- ================================================================
-- Hierarchy: superadmin > admin > companyadmin > clientadmin > moderator > editor > operator > user

INSERT INTO security.roles (code, name, description, level, status, is_platform_role) VALUES
('superadmin', 'Super Admin', 'Platform owner - Full access to all features', 100, 1, TRUE),
('admin', 'Admin', 'System administrator - All company and client operations', 90, 1, TRUE),
('companyadmin', 'Company Admin', 'Company manager - Client operations under own company', 80, 1, FALSE),
('clientadmin', 'Client Admin', 'Client manager - Operations within own client', 70, 1, FALSE),
('moderator', 'Moderator', 'Content moderator - Player editing permissions', 60, 1, FALSE),
('editor', 'Editor', 'Content editor - Banner, slider, content management', 50, 1, FALSE),
('operator', 'Operator', 'Customer service - Player viewing and KYC', 40, 1, FALSE),
('user', 'User', 'Standard user - View only access', 10, 1, FALSE);

-- ================================================================
-- 4. USERS
-- ================================================================
-- Password: deneme
-- Hash: $argon2id$v=19$m=47104,t=1,p=1$/+pv+y99FW+8eHgBq9/RCg$ghMOBDkXj8OLGz8J9RF4m1xnrTm0o78HnG+Bkd2UJ+s
-- WARNING: Change this password immediately after first login!

INSERT INTO security.users (company_id, first_name, last_name, email, username, password, status, language, timezone, currency, country) VALUES
(0, 'Super', 'Admin', 'superadmin@sortisgaming.com', 'superadmin',
 '$argon2id$v=19$m=47104,t=1,p=1$/+pv+y99FW+8eHgBq9/RCg$ghMOBDkXj8OLGz8J9RF4m1xnrTm0o78HnG+Bkd2UJ+s',
 1, 'en', 'Europe/Istanbul', 'EUR', 'MT');

-- ================================================================
-- 5. GLOBAL ROLE ASSIGNMENT
-- ================================================================

-- superadmin@sortisgaming.com → superadmin (global)
INSERT INTO security.user_roles (user_id, role_id, client_id)
SELECT u.id, r.id, NULL FROM security.users u, security.roles r
WHERE u.email = 'superadmin@sortisgaming.com' AND r.code = 'superadmin';

-- ================================================================
-- 6. VALIDATION
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
    RAISE NOTICE 'SORTIS ONE PRODUCTION SEED COMPLETED';
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
    WHEN 'clientadmin' THEN 4 WHEN 'moderator' THEN 5 WHEN 'editor' THEN 6
    WHEN 'operator' THEN 7 WHEN 'user' THEN 8
END;

-- ================================================================
-- PRODUCTION USER SUMMARY
-- ================================================================
--
-- | Email                | Company | Role       |
-- |----------------------|---------|------------|
-- | superadmin@sortisgaming.com | SORTIS  | superadmin |
--
-- Default password: deneme (MUST BE CHANGED!)
-- ================================================================
