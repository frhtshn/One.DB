-- =============================================
-- Security Seed Data
-- Superadmin kullanıcı ve rol tanımları
-- =============================================

-- Superadmin create
INSERT INTO security.users (company_id, first_name, last_name, email, username, password, status, language, timezone, currency, country)
VALUES (0, 'Super', 'Admin', 'superadmin@nucleo.io', 'superadmin', 'zsECiTmx0nxGD5ymsfm0Lw==:YYJDTEdcIwrDmFRqT8fqJ59Fzw81zTKcE1fHBSs9gwo=', 1, 'tr', 'Europe/Istanbul', 'TRY', 'TR')
ON CONFLICT (email) DO NOTHING;

-- Superadmin role create
INSERT INTO security.roles (code, name, description, status, is_platform_role)
VALUES ('superadmin', 'Super Admin', 'Tüm sistem yetkisi.', 1, TRUE)
ON CONFLICT (code) DO UPDATE SET is_platform_role = TRUE;

-- Assign global role to user (tenant_id = NULL for global roles)
INSERT INTO security.user_roles (user_id, role_id, tenant_id)
SELECT u.id, r.id, NULL
FROM security.users u, security.roles r
WHERE u.email = 'superadmin@nucleo.io' AND r.code = 'superadmin'
  AND NOT EXISTS (
    SELECT 1 FROM security.user_roles ur
    WHERE ur.user_id = u.id AND ur.role_id = r.id AND ur.tenant_id IS NULL
  );
