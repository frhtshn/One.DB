-- ================================================================
-- NUCLEO PLATFORM - STAGING/DEV SEED FILE
-- ================================================================
-- Staging ve development ortamları için test verileri.
-- Çalıştırma: psql -U postgres -d nucleo -f core/data/staging_seed.sql
-- ================================================================
-- İÇERİK:
-- 1. TRUNCATE (tüm tablolar)
-- 2. Companies (platform + test companies)
-- 3. Roles + Permissions + Role-Permission mapping
-- 4. Tenants (test tenants)
-- 5. Users (superadmin + admin + test users)
-- 6. User roles (global + tenant)
-- 7. Tenant ayarları (currencies, languages, settings)
-- 8. Menu yapısı (groups + menus + pages)
-- ================================================================
-- NOT: Menu localization için seed_menu_localization.sql'i ÖNCE çalıştırın!
-- ================================================================
-- UYARI: Bu dosya TÜM verileri siler ve yeniden oluşturur!
-- SADECE staging/dev ortamlarında kullanın - PRODUCTION'DA KULLANMAYIN!
-- ================================================================

-- ================================================================
-- 1. TRUNCATE ALL TABLES
-- ================================================================

-- Menu/Presentation
TRUNCATE TABLE presentation.contexts RESTART IDENTITY CASCADE;
TRUNCATE TABLE presentation.tabs RESTART IDENTITY CASCADE;
TRUNCATE TABLE presentation.pages RESTART IDENTITY CASCADE;
TRUNCATE TABLE presentation.submenus RESTART IDENTITY CASCADE;
TRUNCATE TABLE presentation.menus RESTART IDENTITY CASCADE;
TRUNCATE TABLE presentation.menu_groups RESTART IDENTITY CASCADE;

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
SELECT setval('core.tenants_id_seq', 1, false);

-- ================================================================
-- 2. COMPANIES
-- ================================================================

INSERT INTO core.companies (id, company_code, company_name, status, country_code, timezone) VALUES
(0, 'NUCLEO', 'Nucleo Platform', 1, 'TR', 'Europe/Istanbul'),
(1, 'EUROBET', 'EuroBet Gaming Ltd', 1, 'MT', 'Europe/Malta'),
(2, 'CYPRUSPLAY', 'CyprusPlay Entertainment', 1, 'CY', 'Asia/Nicosia'),
(3, 'TURKBET', 'TurkBet Oyun Hizmetleri', 1, 'TR', 'Europe/Istanbul');

SELECT setval('core.companies_id_seq', (SELECT MAX(id) FROM core.companies) + 1);

-- ================================================================
-- 3. ROLES
-- ================================================================
-- Hierarchy: superadmin > admin > companyadmin > tenantadmin > moderator > editor > operator > user

INSERT INTO security.roles (code, name, description, level, status, is_platform_role) VALUES
('superadmin', 'Super Admin', 'Platform sahibi - Tüm yetkiler', 100, 1, TRUE),
('admin', 'Admin', 'Sistem yöneticisi - Tüm company ve tenant işlemleri', 90, 1, TRUE),
('companyadmin', 'Company Admin', 'Şirket yöneticisi - Kendi company altındaki tenant işlemleri', 80, 1, FALSE),
('tenantadmin', 'Tenant Admin', 'Tenant yöneticisi - Kendi tenant içindeki işlemler', 70, 1, FALSE),
('moderator', 'Moderator', 'İçerik moderatörü - Player düzenleme yetkisi', 60, 1, FALSE),
('editor', 'Editor', 'İçerik editörü - Banner, slider, içerik yönetimi', 50, 1, FALSE),
('operator', 'Operator', 'Müşteri hizmetleri - Player görüntüleme ve KYC', 40, 1, FALSE),
('user', 'User', 'Standart kullanıcı - Sadece görüntüleme', 10, 1, FALSE);

-- ================================================================
-- 4. PERMISSIONS
-- ================================================================
-- Scope bazlı permission yapısı:
-- - platform.*  → SuperAdmin only
-- - company.*   → Admin + SuperAdmin
-- - tenant.*    → CompanyAdmin + Admin + SuperAdmin
-- - audit.*     → TenantAdmin + üstü

INSERT INTO security.permissions (code, name, description, category, status) VALUES
-- PLATFORM SCOPE (6) - Sadece SuperAdmin
('platform.menu.manage', 'Menü Yönetimi', 'Menu/Submenu/Page/Tab/Context CRUD işlemleri', 'platform', 1),
('platform.permission.manage', 'Permission Yönetimi', 'Permission tanımlama ve düzenleme', 'platform', 1),
('platform.role.manage', 'Rol Yönetimi', 'Rol tanımlama ve düzenleme', 'platform', 1),
('platform.system.settings', 'Sistem Ayarları', 'Platform ayarları yönetimi', 'platform', 1),
('platform.logs.view', 'Log Görüntüleme', 'Sistem loglarını görüntüleme', 'platform', 1),
('platform.health.view', 'Health Check', 'Sistem sağlık kontrolü', 'platform', 1),

-- COMPANY SCOPE (10) - Admin + SuperAdmin
('company.list', 'Şirket Listesi', 'Tüm şirketleri listeleme', 'company', 1),
('company.view', 'Şirket Görüntüleme', 'Şirket detaylarını görüntüleme', 'company', 1),
('company.create', 'Şirket Oluşturma', 'Yeni şirket oluşturma', 'company', 1),
('company.edit', 'Şirket Düzenleme', 'Şirket bilgilerini düzenleme', 'company', 1),
('company.delete', 'Şirket Silme', 'Şirket silme (soft delete)', 'company', 1),
('company.user.list', 'Company User Listesi', 'Company kullanıcılarını listeleme', 'company', 1),
('company.user.create', 'Company User Oluşturma', 'Company''ye kullanıcı ekleme', 'company', 1),
('company.user.edit', 'Company User Düzenleme', 'Company kullanıcısını düzenleme', 'company', 1),
('company.tenant.create', 'Tenant Oluşturma', 'Yeni tenant oluşturma', 'company', 1),
('company.tenant.edit', 'Tenant Düzenleme', 'Tenant bilgilerini düzenleme', 'company', 1),

-- TENANT SCOPE (6) - CompanyAdmin + Admin + SuperAdmin
('tenant.list', 'Tenant Listesi', 'Tenant listeleme (kendi company)', 'tenant', 1),
('tenant.view', 'Tenant Görüntüleme', 'Tenant detaylarını görüntüleme', 'tenant', 1),
('tenant.edit', 'Tenant Düzenleme', 'Tenant bilgilerini düzenleme (kısıtlı)', 'tenant', 1),
('tenant.user.list', 'Tenant User Listesi', 'Tenant kullanıcılarını listeleme', 'tenant', 1),
('tenant.user.create', 'Tenant User Oluşturma', 'Tenant''a kullanıcı ekleme', 'tenant', 1),
('tenant.user.role.assign', 'Tenant Rol Atama', 'Kullanıcıya tenant rolü atama', 'tenant', 1),
('tenant.user.delete', 'Tenant User Silme', 'Tenant kullanıcısını silme (soft delete)', 'tenant', 1),
('tenant.user.edit', 'Tenant User Düzenleme', 'Tenant kullanıcısını düzenleme (şifre sıfırlama dahil)', 'tenant', 1),

-- TENANT İÇİ SCOPE (3) - TenantAdmin + üstü
('tenant.user.permission.grant', 'Permission Verme', 'Kullanıcıya permission override (grant)', 'tenant', 1),
('tenant.user.permission.deny', 'Permission Kaldırma', 'Kullanıcıdan permission override (deny)', 'tenant', 1),
('tenant.settings.edit', 'Tenant Ayarları', 'Tenant ayarlarını düzenleme', 'tenant', 1),

-- AUDIT SCOPE (3) - TenantAdmin + üstü
('audit.list', 'Audit Log Listesi', 'Audit loglarını listeleme', 'audit', 1),
('audit.view', 'Audit Log Görüntüleme', 'Audit log detayları', 'audit', 1),
('audit.export', 'Audit Log Export', 'Audit loglarını dışa aktarma', 'audit', 1);

-- ================================================================
-- 5. ROLE-PERMISSION MAPPING
-- ================================================================

-- SUPERADMIN: TÜM PERMISSION'LAR
INSERT INTO security.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM security.roles r
CROSS JOIN security.permissions p
WHERE r.code = 'superadmin';

-- ADMIN: company.* + tenant.* + audit.* (platform.* hariç)
INSERT INTO security.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM security.roles r
CROSS JOIN security.permissions p
WHERE r.code = 'admin'
  AND p.category IN ('company', 'tenant', 'audit');

-- COMPANYADMIN: tenant.* + audit.* (company.* hariç)
INSERT INTO security.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM security.roles r
CROSS JOIN security.permissions p
WHERE r.code = 'companyadmin'
  AND p.category IN ('tenant', 'audit');

-- TENANTADMIN: tenant.user.* + tenant.settings.* + tenant.user.permission.* + audit.*
-- NOT: tenant.view/list YOK - TenantAdmin tenant yönetimi sayfasına girmez, kendi tenant'ında çalışır
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
-- Kendi tenant'ındaki kullanıcıları listeleyebilir
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
-- Kendi tenant'ındaki kullanıcıları listeleyebilir (müşteri hizmetleri)
INSERT INTO security.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM security.roles r
CROSS JOIN security.permissions p
WHERE r.code = 'operator'
  AND p.code IN ('tenant.user.list', 'audit.list');

-- USER: audit.list (minimum yetki)
INSERT INTO security.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM security.roles r
CROSS JOIN security.permissions p
WHERE r.code = 'user'
  AND p.code IN ('audit.list');

-- ================================================================
-- 6. TENANTS
-- ================================================================

INSERT INTO core.tenants (company_id, tenant_code, tenant_name, environment, base_currency, default_language, default_country, timezone, status) VALUES
-- EUROBET (Malta) - 2 tenant
(1, 'eurobet_eu', 'EuroBet Europe', 'prod', 'EUR', 'en', 'MT', 'Europe/Malta', 1),
(1, 'eurobet_uk', 'EuroBet UK', 'prod', 'GBP', 'en', 'GB', 'Europe/London', 1),
-- CYPRUSPLAY (Kıbrıs) - 1 tenant
(2, 'cyprus_main', 'CyprusPlay Main', 'prod', 'EUR', 'en', 'CY', 'Asia/Nicosia', 1),
-- TURKBET (Türkiye) - 1 tenant
(3, 'turkbet_tr', 'TurkBet Türkiye', 'prod', 'TRY', 'tr', 'TR', 'Europe/Istanbul', 1);

-- ================================================================
-- 7. USERS
-- ================================================================
-- Şifre: deneme (tüm kullanıcılar için aynı)
-- Hash: zsECiTmx0nxGD5ymsfm0Lw==:YYJDTEdcIwrDmFRqT8fqJ59Fzw81zTKcE1fHBSs9gwo=

INSERT INTO security.users (company_id, first_name, last_name, email, username, password, status, language, timezone, currency) VALUES
-- Superadmin (NUCLEO)
-- UYARI: Production'da şifre MUTLAKA değiştirilmeli!
(0, 'Super', 'Admin', 'superadmin@nucleo.io', 'superadmin',
 'zsECiTmx0nxGD5ymsfm0Lw==:YYJDTEdcIwrDmFRqT8fqJ59Fzw81zTKcE1fHBSs9gwo=',
 1, 'tr', 'Europe/Istanbul', 'TRY'),

-- Platform Admin (NUCLEO)
(0, 'System', 'Admin', 'admin@nucleo.io', 'admin',
 'zsECiTmx0nxGD5ymsfm0Lw==:YYJDTEdcIwrDmFRqT8fqJ59Fzw81zTKcE1fHBSs9gwo=',
 1, 'en', 'Europe/Istanbul', 'EUR'),

-- CompanyAdmin - EUROBET (Malta)
(1, 'James', 'Wilson', 'eurobet@nucleo.io', 'eurobet',
 'zsECiTmx0nxGD5ymsfm0Lw==:YYJDTEdcIwrDmFRqT8fqJ59Fzw81zTKcE1fHBSs9gwo=',
 1, 'en', 'Europe/Malta', 'EUR'),

-- CompanyAdmin - CYPRUSPLAY (Kıbrıs)
(2, 'Andreas', 'Georgiou', 'cyprus@nucleo.io', 'cyprus',
 'zsECiTmx0nxGD5ymsfm0Lw==:YYJDTEdcIwrDmFRqT8fqJ59Fzw81zTKcE1fHBSs9gwo=',
 1, 'en', 'Asia/Nicosia', 'EUR'),

-- CompanyAdmin - TURKBET (Türkiye)
(3, 'Ahmet', 'Yılmaz', 'turkbet@nucleo.io', 'turkbet',
 'zsECiTmx0nxGD5ymsfm0Lw==:YYJDTEdcIwrDmFRqT8fqJ59Fzw81zTKcE1fHBSs9gwo=',
 1, 'tr', 'Europe/Istanbul', 'TRY'),

-- TenantAdmin - eurobet_eu
(1, 'Maria', 'Santos', 'eurobet.eu@nucleo.io', 'eurobet_eu',
 'zsECiTmx0nxGD5ymsfm0Lw==:YYJDTEdcIwrDmFRqT8fqJ59Fzw81zTKcE1fHBSs9gwo=',
 1, 'en', 'Europe/Malta', 'EUR'),

-- TenantAdmin - cyprus_main
(2, 'Nikos', 'Papadopoulos', 'cyprus.admin@nucleo.io', 'cyprus_admin',
 'zsECiTmx0nxGD5ymsfm0Lw==:YYJDTEdcIwrDmFRqT8fqJ59Fzw81zTKcE1fHBSs9gwo=',
 1, 'en', 'Asia/Nicosia', 'EUR'),

-- TenantAdmin - turkbet_tr
(3, 'Mehmet', 'Demir', 'turkbet.admin@nucleo.io', 'turkbet_admin',
 'zsECiTmx0nxGD5ymsfm0Lw==:YYJDTEdcIwrDmFRqT8fqJ59Fzw81zTKcE1fHBSs9gwo=',
 1, 'tr', 'Europe/Istanbul', 'TRY'),

-- Moderator - turkbet_tr
(3, 'Ayşe', 'Kaya', 'turkbet.mod@nucleo.io', 'turkbet_mod',
 'zsECiTmx0nxGD5ymsfm0Lw==:YYJDTEdcIwrDmFRqT8fqJ59Fzw81zTKcE1fHBSs9gwo=',
 1, 'tr', 'Europe/Istanbul', 'TRY'),

-- Editor - turkbet_tr
(3, 'Zeynep', 'Çelik', 'turkbet.edit@nucleo.io', 'turkbet_edit',
 'zsECiTmx0nxGD5ymsfm0Lw==:YYJDTEdcIwrDmFRqT8fqJ59Fzw81zTKcE1fHBSs9gwo=',
 1, 'tr', 'Europe/Istanbul', 'TRY'),

-- Operator - turkbet_tr
(3, 'Ali', 'Öztürk', 'turkbet.op@nucleo.io', 'turkbet_op',
 'zsECiTmx0nxGD5ymsfm0Lw==:YYJDTEdcIwrDmFRqT8fqJ59Fzw81zTKcE1fHBSs9gwo=',
 1, 'tr', 'Europe/Istanbul', 'TRY'),

-- User - eurobet_eu
(1, 'John', 'Smith', 'eurobet.user@nucleo.io', 'eurobet_user',
 'zsECiTmx0nxGD5ymsfm0Lw==:YYJDTEdcIwrDmFRqT8fqJ59Fzw81zTKcE1fHBSs9gwo=',
 1, 'en', 'Europe/Malta', 'EUR');

-- ================================================================
-- 8. GLOBAL ROL ATAMALARI (security.user_roles - tenant_id = NULL)
-- ================================================================

-- superadmin@nucleo.io → superadmin (global)
INSERT INTO security.user_roles (user_id, role_id, tenant_id)
SELECT u.id, r.id, NULL FROM security.users u, security.roles r
WHERE u.email = 'superadmin@nucleo.io' AND r.code = 'superadmin';

-- admin@nucleo.io → admin (global)
INSERT INTO security.user_roles (user_id, role_id, tenant_id)
SELECT u.id, r.id, NULL FROM security.users u, security.roles r
WHERE u.email = 'admin@nucleo.io' AND r.code = 'admin';

-- eurobet@nucleo.io → companyadmin (global)
INSERT INTO security.user_roles (user_id, role_id, tenant_id)
SELECT u.id, r.id, NULL FROM security.users u, security.roles r
WHERE u.email = 'eurobet@nucleo.io' AND r.code = 'companyadmin';

-- cyprus@nucleo.io → companyadmin (global)
INSERT INTO security.user_roles (user_id, role_id, tenant_id)
SELECT u.id, r.id, NULL FROM security.users u, security.roles r
WHERE u.email = 'cyprus@nucleo.io' AND r.code = 'companyadmin';

-- turkbet@nucleo.io → companyadmin (global)
INSERT INTO security.user_roles (user_id, role_id, tenant_id)
SELECT u.id, r.id, NULL FROM security.users u, security.roles r
WHERE u.email = 'turkbet@nucleo.io' AND r.code = 'companyadmin';

-- ================================================================
-- 9. TENANT ROL ATAMALARI (security.user_roles - tenant_id = değer)
-- ================================================================

-- eurobet.eu@nucleo.io → tenantadmin @ eurobet_eu
INSERT INTO security.user_roles (user_id, role_id, tenant_id)
SELECT u.id, r.id, t.id
FROM security.users u, security.roles r, core.tenants t
WHERE u.email = 'eurobet.eu@nucleo.io' AND r.code = 'tenantadmin' AND t.tenant_code = 'eurobet_eu';

-- cyprus.admin@nucleo.io → tenantadmin @ cyprus_main
INSERT INTO security.user_roles (user_id, role_id, tenant_id)
SELECT u.id, r.id, t.id
FROM security.users u, security.roles r, core.tenants t
WHERE u.email = 'cyprus.admin@nucleo.io' AND r.code = 'tenantadmin' AND t.tenant_code = 'cyprus_main';

-- turkbet.admin@nucleo.io → tenantadmin @ turkbet_tr
INSERT INTO security.user_roles (user_id, role_id, tenant_id)
SELECT u.id, r.id, t.id
FROM security.users u, security.roles r, core.tenants t
WHERE u.email = 'turkbet.admin@nucleo.io' AND r.code = 'tenantadmin' AND t.tenant_code = 'turkbet_tr';

-- turkbet.mod@nucleo.io → moderator @ turkbet_tr
INSERT INTO security.user_roles (user_id, role_id, tenant_id)
SELECT u.id, r.id, t.id
FROM security.users u, security.roles r, core.tenants t
WHERE u.email = 'turkbet.mod@nucleo.io' AND r.code = 'moderator' AND t.tenant_code = 'turkbet_tr';

-- turkbet.edit@nucleo.io → editor @ turkbet_tr
INSERT INTO security.user_roles (user_id, role_id, tenant_id)
SELECT u.id, r.id, t.id
FROM security.users u, security.roles r, core.tenants t
WHERE u.email = 'turkbet.edit@nucleo.io' AND r.code = 'editor' AND t.tenant_code = 'turkbet_tr';

-- turkbet.op@nucleo.io → operator @ turkbet_tr
INSERT INTO security.user_roles (user_id, role_id, tenant_id)
SELECT u.id, r.id, t.id
FROM security.users u, security.roles r, core.tenants t
WHERE u.email = 'turkbet.op@nucleo.io' AND r.code = 'operator' AND t.tenant_code = 'turkbet_tr';

-- eurobet.user@nucleo.io → user @ eurobet_eu
INSERT INTO security.user_roles (user_id, role_id, tenant_id)
SELECT u.id, r.id, t.id
FROM security.users u, security.roles r, core.tenants t
WHERE u.email = 'eurobet.user@nucleo.io' AND r.code = 'user' AND t.tenant_code = 'eurobet_eu';

-- ================================================================
-- 10. TENANT ERİŞİM İZİNLERİ (security.user_allowed_tenants)
-- ================================================================

-- TenantAdmin'ler kendi tenant'larına
INSERT INTO security.user_allowed_tenants (user_id, tenant_id)
SELECT u.id, t.id FROM security.users u, core.tenants t
WHERE u.email = 'eurobet.eu@nucleo.io' AND t.tenant_code = 'eurobet_eu';

INSERT INTO security.user_allowed_tenants (user_id, tenant_id)
SELECT u.id, t.id FROM security.users u, core.tenants t
WHERE u.email = 'cyprus.admin@nucleo.io' AND t.tenant_code = 'cyprus_main';

INSERT INTO security.user_allowed_tenants (user_id, tenant_id)
SELECT u.id, t.id FROM security.users u, core.tenants t
WHERE u.email = 'turkbet.admin@nucleo.io' AND t.tenant_code = 'turkbet_tr';

-- Moderator, Editor, Operator turkbet_tr'ye
INSERT INTO security.user_allowed_tenants (user_id, tenant_id)
SELECT u.id, t.id FROM security.users u, core.tenants t
WHERE u.email = 'turkbet.mod@nucleo.io' AND t.tenant_code = 'turkbet_tr';

INSERT INTO security.user_allowed_tenants (user_id, tenant_id)
SELECT u.id, t.id FROM security.users u, core.tenants t
WHERE u.email = 'turkbet.edit@nucleo.io' AND t.tenant_code = 'turkbet_tr';

INSERT INTO security.user_allowed_tenants (user_id, tenant_id)
SELECT u.id, t.id FROM security.users u, core.tenants t
WHERE u.email = 'turkbet.op@nucleo.io' AND t.tenant_code = 'turkbet_tr';

-- User eurobet_eu'ya
INSERT INTO security.user_allowed_tenants (user_id, tenant_id)
SELECT u.id, t.id FROM security.users u, core.tenants t
WHERE u.email = 'eurobet.user@nucleo.io' AND t.tenant_code = 'eurobet_eu';

-- ================================================================
-- 11. TENANT AYARLARI
-- ================================================================

-- Tenant Para Birimleri
INSERT INTO core.tenant_currencies (tenant_id, currency_code, is_enabled)
SELECT t.id, c.code, true FROM core.tenants t
CROSS JOIN (VALUES ('EUR'), ('USD'), ('GBP')) AS c(code)
WHERE t.tenant_code = 'eurobet_eu';

INSERT INTO core.tenant_currencies (tenant_id, currency_code, is_enabled)
SELECT t.id, c.code, true FROM core.tenants t
CROSS JOIN (VALUES ('GBP'), ('EUR'), ('USD')) AS c(code)
WHERE t.tenant_code = 'eurobet_uk';

INSERT INTO core.tenant_currencies (tenant_id, currency_code, is_enabled)
SELECT t.id, c.code, true FROM core.tenants t
CROSS JOIN (VALUES ('EUR'), ('USD')) AS c(code)
WHERE t.tenant_code = 'cyprus_main';

INSERT INTO core.tenant_currencies (tenant_id, currency_code, is_enabled)
SELECT t.id, c.code, true FROM core.tenants t
CROSS JOIN (VALUES ('TRY'), ('EUR'), ('USD')) AS c(code)
WHERE t.tenant_code = 'turkbet_tr';

-- Tenant Dilleri (tüm tenant'lar için en ve tr)
INSERT INTO core.tenant_languages (tenant_id, language_code, is_enabled)
SELECT t.id, l.code, true FROM core.tenants t
CROSS JOIN (VALUES ('en'), ('tr')) AS l(code);

-- Tenant Ayarları
-- SMS API Ayarları
INSERT INTO core.tenant_settings (tenant_id, category, setting_key, setting_value, description)
SELECT t.id, 'Integration', 'sms_provider',
    '{"provider": "twilio", "account_sid": "AC_STAGING_SID", "auth_token": "STAGING_AUTH_TOKEN", "from_number": "+15005550006", "enabled": true, "sandbox_mode": true}'::jsonb,
    'SMS provider configuration (Twilio)'
FROM core.tenants t;

-- Email Ayarları
INSERT INTO core.tenant_settings (tenant_id, category, setting_key, setting_value, description)
SELECT t.id, 'Integration', 'email_provider',
    '{"provider": "smtp", "host": "smtp.mailtrap.io", "port": 587, "username": "staging_user", "password": "staging_pass", "from_address": "noreply@staging.nucleo.io", "from_name": "Nucleo Platform", "use_ssl": true, "enabled": true}'::jsonb,
    'Email/SMTP provider configuration'
FROM core.tenants t;

-- Tenant Ana DB Bağlantısı (tenant)
INSERT INTO core.tenant_settings (tenant_id, category, setting_key, setting_value, description)
SELECT t.id, 'Database', 'connection_tenant',
    '{"host": "207.180.241.230", "port": 5433, "database": "tenant", "username": "postgres", "password": "NucleoPostgres2026", "ssl_mode": "prefer", "min_pool_size": 5, "max_pool_size": 50, "connection_timeout": 30, "command_timeout": 60, "replica_enabled": false, "replica_port": 5434, "replica_min_pool_size": 2, "replica_max_pool_size": 10}'::jsonb,
    'Tenant main database connection settings'
FROM core.tenants t;

-- Tenant Audit DB Bağlantısı
INSERT INTO core.tenant_settings (tenant_id, category, setting_key, setting_value, description)
SELECT t.id, 'Database', 'connection_tenant_audit',
    '{"host": "207.180.241.230", "port": 5433, "database": "tenant_audit", "username": "postgres", "password": "NucleoPostgres2026", "ssl_mode": "prefer", "min_pool_size": 2, "max_pool_size": 20, "connection_timeout": 30, "command_timeout": 60, "replica_enabled": false, "replica_port": 5434, "replica_min_pool_size": 1, "replica_max_pool_size": 5}'::jsonb,
    'Tenant audit database connection settings'
FROM core.tenants t;

-- Tenant Log DB Bağlantısı
INSERT INTO core.tenant_settings (tenant_id, category, setting_key, setting_value, description)
SELECT t.id, 'Database', 'connection_tenant_log',
    '{"host": "207.180.241.230", "port": 5433, "database": "tenant_log", "username": "postgres", "password": "NucleoPostgres2026", "ssl_mode": "prefer", "min_pool_size": 2, "max_pool_size": 30, "connection_timeout": 30, "command_timeout": 60, "replica_enabled": false, "replica_port": 5434, "replica_min_pool_size": 1, "replica_max_pool_size": 5}'::jsonb,
    'Tenant log database connection settings'
FROM core.tenants t;

-- Tenant Affiliate DB Bağlantısı
INSERT INTO core.tenant_settings (tenant_id, category, setting_key, setting_value, description)
SELECT t.id, 'Database', 'connection_tenant_affiliate',
    '{"host": "207.180.241.230", "port": 5433, "database": "tenant_affiliate", "username": "postgres", "password": "NucleoPostgres2026", "ssl_mode": "prefer", "min_pool_size": 2, "max_pool_size": 20, "connection_timeout": 30, "command_timeout": 60, "replica_enabled": false, "replica_port": 5434, "replica_min_pool_size": 1, "replica_max_pool_size": 5}'::jsonb,
    'Tenant affiliate database connection settings'
FROM core.tenants t;

-- Tenant Report DB Bağlantısı
INSERT INTO core.tenant_settings (tenant_id, category, setting_key, setting_value, description)
SELECT t.id, 'Database', 'connection_tenant_report',
    '{"host": "207.180.241.230", "port": 5433, "database": "tenant_report", "username": "postgres", "password": "NucleoPostgres2026", "ssl_mode": "prefer", "min_pool_size": 2, "max_pool_size": 30, "connection_timeout": 30, "command_timeout": 120, "replica_enabled": true, "replica_port": 5434, "replica_min_pool_size": 2, "replica_max_pool_size": 15}'::jsonb,
    'Tenant report database connection settings (replica enabled for heavy queries)'
FROM core.tenants t;

-- ================================================================
-- 12. MENU GROUPS
-- ================================================================
-- NOT: Menu localization seed_menu_localization.sql dosyasında.
-- ================================================================
-- ================================================================

INSERT INTO presentation.menu_groups (code, title_localization_key, order_index, is_active) VALUES
('platform', 'ui.menu-group.platform', 1, TRUE),
('companies', 'ui.menu-group.companies', 2, TRUE),
('tenants', 'ui.menu-group.tenants', 3, TRUE),
('audit', 'ui.menu-group.audit', 4, TRUE);

-- ================================================================
-- 13. MENUS
-- ================================================================

-- Platform Group
INSERT INTO presentation.menus (menu_group_id, code, title_localization_key, icon, order_index, required_permission, is_active)
SELECT mg.id, v.code, v.title_key, v.icon, v.ord, v.perm, TRUE
FROM presentation.menu_groups mg
CROSS JOIN (VALUES
    ('system', 'ui.menu.system', 'pi pi-cog', 1, 'platform.health.view'),
    ('rbac', 'ui.menu.rbac', 'pi pi-shield', 2, 'platform.role.manage')
) AS v(code, title_key, icon, ord, perm)
WHERE mg.code = 'platform';

-- Companies Group
INSERT INTO presentation.menus (menu_group_id, code, title_localization_key, icon, order_index, required_permission, is_active)
SELECT mg.id, v.code, v.title_key, v.icon, v.ord, v.perm, TRUE
FROM presentation.menu_groups mg
CROSS JOIN (VALUES
    ('companies', 'ui.menu.companies', 'pi pi-building', 1, 'company.list'),
    ('company-users', 'ui.menu.company-users', 'pi pi-users', 2, 'company.user.list')
) AS v(code, title_key, icon, ord, perm)
WHERE mg.code = 'companies';

-- Tenants Group
INSERT INTO presentation.menus (menu_group_id, code, title_localization_key, icon, order_index, required_permission, is_active)
SELECT mg.id, v.code, v.title_key, v.icon, v.ord, v.perm, TRUE
FROM presentation.menu_groups mg
CROSS JOIN (VALUES
    ('tenants', 'ui.menu.tenants', 'pi pi-sitemap', 1, 'tenant.list'),
    ('tenant-users', 'ui.menu.tenant-users', 'pi pi-users', 2, 'tenant.user.list'),
    ('tenant-settings', 'ui.menu.tenant-settings', 'pi pi-cog', 3, 'tenant.settings.edit')
) AS v(code, title_key, icon, ord, perm)
WHERE mg.code = 'tenants';

-- Audit Group
INSERT INTO presentation.menus (menu_group_id, code, title_localization_key, icon, order_index, required_permission, is_active)
SELECT mg.id, v.code, v.title_key, v.icon, v.ord, v.perm, TRUE
FROM presentation.menu_groups mg
CROSS JOIN (VALUES
    ('audit-logs', 'ui.menu.audit-logs', 'pi pi-list', 1, 'audit.list')
) AS v(code, title_key, icon, ord, perm)
WHERE mg.code = 'audit';

-- ================================================================
-- 14. SUBMENUS
-- ================================================================

-- System Menu Submenus
INSERT INTO presentation.submenus (menu_id, code, title_localization_key, route, order_index, required_permission, is_active)
SELECT m.id, v.code, v.title_key, v.route, v.ord, v.perm, TRUE
FROM presentation.menus m
CROSS JOIN (VALUES
    ('health', 'ui.submenu.health', '/admin/health', 1, 'platform.health.view'),
    ('logs', 'ui.submenu.logs', '/admin/logs', 2, 'platform.logs.view'),
    ('system-settings', 'ui.submenu.system-settings', '/admin/system-settings', 3, 'platform.system.settings')
) AS v(code, title_key, route, ord, perm)
WHERE m.code = 'system';

-- RBAC Menu Submenus
INSERT INTO presentation.submenus (menu_id, code, title_localization_key, route, order_index, required_permission, is_active)
SELECT m.id, v.code, v.title_key, v.route, v.ord, v.perm, TRUE
FROM presentation.menus m
CROSS JOIN (VALUES
    ('menus', 'ui.submenu.menus', '/admin/menus', 1, 'platform.menu.manage'),
    ('roles', 'ui.submenu.roles', '/admin/roles', 2, 'platform.role.manage'),
    ('permissions', 'ui.submenu.permissions', '/admin/permissions', 3, 'platform.permission.manage')
) AS v(code, title_key, route, ord, perm)
WHERE m.code = 'rbac';

-- ================================================================
-- 15. PAGES
-- ================================================================

-- System Submenu Pages
INSERT INTO presentation.pages (menu_id, submenu_id, code, route, title_localization_key, required_permission, order_index, is_active)
SELECT NULL, s.id, v.code, v.route, v.title_key, v.perm, 1, TRUE
FROM presentation.submenus s
JOIN (VALUES
    ('health', 'page-health', '/admin/health', 'ui.page.health', 'platform.health.view'),
    ('logs', 'page-logs', '/admin/logs', 'ui.page.logs', 'platform.logs.view'),
    ('system-settings', 'page-system-settings', '/admin/system-settings', 'ui.page.system-settings', 'platform.system.settings'),
    ('menus', 'page-menu-management', '/admin/menus', 'ui.page.menu-management', 'platform.menu.manage'),
    ('roles', 'page-roles', '/admin/roles', 'ui.page.roles', 'platform.role.manage'),
    ('permissions', 'page-permissions', '/admin/permissions', 'ui.page.permissions', 'platform.permission.manage')
) AS v(submenu_code, code, route, title_key, perm) ON s.code = v.submenu_code;

-- Companies Menu Pages (detail sayfaları menüde görünmez, listeden navigasyon ile açılır)
INSERT INTO presentation.pages (menu_id, submenu_id, code, route, title_localization_key, required_permission, order_index, is_active)
SELECT m.id, NULL, v.code, v.route, v.title_key, v.perm, v.ord, TRUE
FROM presentation.menus m
JOIN (VALUES
    ('companies', 'page-companies', '/admin/companies', 'ui.page.companies', 'company.list', 1),
    ('company-users', 'page-company-users', '/admin/company-users', 'ui.page.company-users', 'company.user.list', 1)
) AS v(menu_code, code, route, title_key, perm, ord) ON m.code = v.menu_code;

-- Tenants Menu Pages (detail sayfaları menüde görünmez, listeden navigasyon ile açılır)
INSERT INTO presentation.pages (menu_id, submenu_id, code, route, title_localization_key, required_permission, order_index, is_active)
SELECT m.id, NULL, v.code, v.route, v.title_key, v.perm, v.ord, TRUE
FROM presentation.menus m
JOIN (VALUES
    ('tenants', 'page-tenants', '/admin/tenants', 'ui.page.tenants', 'tenant.list', 1),
    ('tenant-users', 'page-tenant-users', '/admin/tenant-users', 'ui.page.tenant-users', 'tenant.user.list', 1),
    ('tenant-settings', 'page-tenant-settings', '/admin/tenant-settings', 'ui.page.tenant-settings', 'tenant.settings.edit', 1)
) AS v(menu_code, code, route, title_key, perm, ord) ON m.code = v.menu_code;

-- Audit Menu Pages
INSERT INTO presentation.pages (menu_id, submenu_id, code, route, title_localization_key, required_permission, order_index, is_active)
SELECT m.id, NULL, v.code, v.route, v.title_key, v.perm, v.ord, TRUE
FROM presentation.menus m
JOIN (VALUES
    ('audit-logs', 'page-audit-logs', '/admin/audit-logs', 'ui.page.audit-logs', 'audit.list', 1)
) AS v(menu_code, code, route, title_key, perm, ord) ON m.code = v.menu_code;

-- Detail Pages (menüye bağlı, route parametreli olduğu için frontend'de sidebar'dan filtrelenir)
INSERT INTO presentation.pages (menu_id, submenu_id, code, route, title_localization_key, required_permission, order_index, is_active)
SELECT m.id, NULL, v.code, v.route, v.title_key, v.perm, v.ord, TRUE
FROM presentation.menus m
JOIN (VALUES
    ('companies', 'page-company-detail', '/admin/companies/:id', 'ui.page.company-detail', 'company.view', 2),
    ('tenants', 'page-tenant-detail', '/admin/tenants/:id', 'ui.page.tenant-detail', 'tenant.view', 2),
    ('tenant-users', 'page-tenant-user-detail', '/admin/tenant-users/:id', 'ui.page.tenant-user-detail', 'tenant.user.list', 2),
    ('audit-logs', 'page-audit-log-detail', '/admin/audit-logs/:id', 'ui.page.audit-log-detail', 'audit.view', 2)
) AS v(menu_code, code, route, title_key, perm, ord) ON m.code = v.menu_code;

-- ================================================================
-- 16. CONTEXTS (Sayfa içi dinamik bölümler)
-- ================================================================
-- context_type: section, table, card, action, field
-- permission_edit: düzenleme yetkisi
-- permission_readonly: görüntüleme yetkisi (edit yoksa readonly kontrol edilir)

INSERT INTO presentation.contexts (page_id, code, context_type, label_localization_key, permission_edit, permission_readonly, is_active)
SELECT p.id, v.code, v.ctx_type, v.label_key, v.perm_edit, v.perm_readonly, TRUE
FROM presentation.pages p
JOIN (VALUES
    -- Company Detail Contexts (context_type: field, action, section, button)
    ('page-company-detail', 'company-info', 'section', 'ui.context.company-info', 'company.edit', 'company.view'),
    ('page-company-detail', 'company-tenants', 'section', 'ui.context.company-tenants', 'company.tenant.create', 'tenant.list'),
    ('page-company-detail', 'company-users', 'section', 'ui.context.company-users', 'company.user.create', 'company.user.list'),

    -- Tenant Detail Contexts
    ('page-tenant-detail', 'tenant-info', 'section', 'ui.context.tenant-info', 'tenant.edit', 'tenant.view'),
    ('page-tenant-detail', 'tenant-users', 'section', 'ui.context.tenant-users', 'tenant.user.create', 'tenant.user.list'),
    ('page-tenant-detail', 'tenant-settings', 'section', 'ui.context.tenant-settings', 'tenant.settings.edit', 'tenant.view')
) AS v(page_code, code, ctx_type, label_key, perm_edit, perm_readonly) ON p.code = v.page_code;

-- ================================================================
-- 17. DOĞRULAMA
-- ================================================================

DO $$
DECLARE
    v_companies INT; v_tenants INT; v_roles INT; v_permissions INT;
    v_users INT; v_global_roles INT; v_tenant_roles INT;
    v_menu_groups INT; v_menus INT; v_submenus INT; v_pages INT;
BEGIN
    SELECT COUNT(*) INTO v_companies FROM core.companies;
    SELECT COUNT(*) INTO v_tenants FROM core.tenants;
    SELECT COUNT(*) INTO v_roles FROM security.roles;
    SELECT COUNT(*) INTO v_permissions FROM security.permissions;
    SELECT COUNT(*) INTO v_users FROM security.users;
    SELECT COUNT(*) INTO v_global_roles FROM security.user_roles WHERE tenant_id IS NULL;
    SELECT COUNT(*) INTO v_tenant_roles FROM security.user_roles WHERE tenant_id IS NOT NULL;
    SELECT COUNT(*) INTO v_menu_groups FROM presentation.menu_groups;
    SELECT COUNT(*) INTO v_menus FROM presentation.menus;
    SELECT COUNT(*) INTO v_submenus FROM presentation.submenus;
    SELECT COUNT(*) INTO v_pages FROM presentation.pages;

    RAISE NOTICE '================================================';
    RAISE NOTICE 'NUCLEO PLATFORM SEED TAMAMLANDI';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Companies: %', v_companies;
    RAISE NOTICE 'Tenants: %', v_tenants;
    RAISE NOTICE 'Roles: %', v_roles;
    RAISE NOTICE 'Permissions: %', v_permissions;
    RAISE NOTICE 'Users: %', v_users;
    RAISE NOTICE 'Global Role Assignments: %', v_global_roles;
    RAISE NOTICE 'Tenant Role Assignments: %', v_tenant_roles;
    RAISE NOTICE 'Menu Groups: %', v_menu_groups;
    RAISE NOTICE 'Menus: %', v_menus;
    RAISE NOTICE 'Submenus: %', v_submenus;
    RAISE NOTICE 'Pages: %', v_pages;
    RAISE NOTICE '================================================';
END $$;

-- Role-Permission özeti
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
-- TEST KULLANICILARI ÖZETİ
-- ================================================================
--
-- | Email                  | Company     | Role                         |
-- |------------------------|-------------|------------------------------|
-- | superadmin@nucleo.io   | NUCLEO      | superadmin                   |
-- | admin@nucleo.io        | NUCLEO      | admin                        |
-- | eurobet@nucleo.io      | EUROBET     | companyadmin                 |
-- | cyprus@nucleo.io       | CYPRUSPLAY  | companyadmin                 |
-- | turkbet@nucleo.io      | TURKBET     | companyadmin                 |
-- | eurobet.eu@nucleo.io   | EUROBET     | tenantadmin@eurobet_eu       |
-- | cyprus.admin@nucleo.io | CYPRUSPLAY  | tenantadmin@cyprus_main      |
-- | turkbet.admin@nucleo.io| TURKBET     | tenantadmin@turkbet_tr       |
-- | turkbet.mod@nucleo.io  | TURKBET     | moderator@turkbet_tr         |
-- | turkbet.edit@nucleo.io | TURKBET     | editor@turkbet_tr            |
-- | turkbet.op@nucleo.io   | TURKBET     | operator@turkbet_tr          |
-- | eurobet.user@nucleo.io | EUROBET     | user@eurobet_eu              |
--
-- Tüm şifreler: deneme
-- ================================================================
