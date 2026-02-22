-- ================================================================
-- NUCLEO PLATFORM - TEST SEED DATA
-- ================================================================
-- Staging ve development ortamları için test verileri.
-- Companies, roles, tenants, users, settings, compliance.
-- Menu/presentation yapısı bu dosyada YOK — seed_presentation.sql'de.
-- ================================================================
-- ÇALIŞTIRMA SIRASI:
--   1. staging_seed_menu_localization.sql  (localization key'ler)
--   2. staging_seed.sql                       (bu dosya)
--   3. permissions_full.sql                (permissions - UPSERT)
--   4. role_permissions_full.sql           (role mapping - UPSERT)
--   5. seed_presentation.sql               (menu yapısı)
-- ================================================================
-- UYARI: Bu dosya TÜM test verilerini siler ve yeniden oluşturur!
-- SADECE staging/dev ortamlarında kullanın - PRODUCTION'DA KULLANMAYIN!
-- ================================================================

-- ================================================================
-- 1. TRUNCATE ALL TABLES
-- ================================================================
-- NOT: permissions ve role_permissions TRUNCATE edilmiyor
-- Bunlar permissions_full.sql ve role_permissions_full.sql'de yönetiliyor
-- NOT: presentation tabloları TRUNCATE edilmiyor
-- Bunlar seed_presentation.sql'de yönetiliyor

-- Security (permissions hariç)
TRUNCATE TABLE security.user_password_history RESTART IDENTITY CASCADE;
TRUNCATE TABLE security.company_password_policy RESTART IDENTITY CASCADE;
TRUNCATE TABLE security.user_allowed_tenants RESTART IDENTITY CASCADE;
TRUNCATE TABLE security.user_roles RESTART IDENTITY CASCADE;
TRUNCATE TABLE security.users RESTART IDENTITY CASCADE;
TRUNCATE TABLE security.roles RESTART IDENTITY CASCADE;

-- Core
TRUNCATE TABLE core.tenant_jurisdictions RESTART IDENTITY CASCADE;
TRUNCATE TABLE core.tenant_settings RESTART IDENTITY CASCADE;
TRUNCATE TABLE core.tenant_languages RESTART IDENTITY CASCADE;
TRUNCATE TABLE core.tenant_currencies RESTART IDENTITY CASCADE;
TRUNCATE TABLE core.tenant_cryptocurrencies RESTART IDENTITY CASCADE;
TRUNCATE TABLE core.tenants RESTART IDENTITY CASCADE;
TRUNCATE TABLE core.companies RESTART IDENTITY CASCADE;

-- Compliance/Catalog
TRUNCATE TABLE catalog.responsible_gaming_policies RESTART IDENTITY CASCADE;
TRUNCATE TABLE catalog.kyc_level_requirements RESTART IDENTITY CASCADE;
TRUNCATE TABLE catalog.kyc_document_requirements RESTART IDENTITY CASCADE;
TRUNCATE TABLE catalog.kyc_policies RESTART IDENTITY CASCADE;
TRUNCATE TABLE catalog.jurisdictions RESTART IDENTITY CASCADE;

-- Sequence reset
SELECT setval('core.companies_id_seq', 1, false);
SELECT setval('core.tenants_id_seq', 1, false);

-- ================================================================
-- 2. COMPANIES (4)
-- ================================================================

INSERT INTO core.companies (id, company_code, company_name, status, country_code, timezone) VALUES
(0, 'NUCLEO', 'Nucleo Platform', 1, 'TR', 'Europe/Istanbul'),
(1, 'EUROBET', 'EuroBet Gaming Ltd', 1, 'MT', 'Europe/Malta'),
(2, 'CYPRUSPLAY', 'CyprusPlay Entertainment', 1, 'CY', 'Asia/Nicosia'),
(3, 'TURKBET', 'TurkBet Oyun Teknolojileri', 1, 'TR', 'Europe/Istanbul');

SELECT setval('core.companies_id_seq', (SELECT MAX(id) FROM core.companies) + 1);

-- ================================================================
-- 3. ROLES (8)
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
-- 4. TENANTS (4)
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
-- 5. USERS (12 — sadeleştirilmiş)
-- ================================================================
-- Şifre: deneme (tüm kullanıcılar için aynı)
-- Hash: $argon2id$v=19$m=47104,t=1,p=1$/+pv+y99FW+8eHgBq9/RCg$ghMOBDkXj8OLGz8J9RF4m1xnrTm0o78HnG+Bkd2UJ+s

INSERT INTO security.users (company_id, first_name, last_name, email, username, password, status, language, timezone, currency, country) VALUES
-- Superadmin (NUCLEO)
-- UYARI: Production'da şifre MUTLAKA değiştirilmeli!
(0, 'Super', 'Admin', 'superadmin@nucleo.io', 'superadmin',
 '$argon2id$v=19$m=47104,t=1,p=1$/+pv+y99FW+8eHgBq9/RCg$ghMOBDkXj8OLGz8J9RF4m1xnrTm0o78HnG+Bkd2UJ+s',
 1, 'tr', 'Europe/Istanbul', 'TRY', 'TR'),

-- Platform Admin (NUCLEO)
(0, 'System', 'Admin', 'admin@nucleo.io', 'admin',
 '$argon2id$v=19$m=47104,t=1,p=1$/+pv+y99FW+8eHgBq9/RCg$ghMOBDkXj8OLGz8J9RF4m1xnrTm0o78HnG+Bkd2UJ+s',
 1, 'en', 'Europe/Istanbul', 'EUR', 'MT'),

-- CompanyAdmin - EUROBET (Malta)
(1, 'James', 'Wilson', 'eurobet@nucleo.io', 'eurobet',
 '$argon2id$v=19$m=47104,t=1,p=1$/+pv+y99FW+8eHgBq9/RCg$ghMOBDkXj8OLGz8J9RF4m1xnrTm0o78HnG+Bkd2UJ+s',
 1, 'en', 'Europe/Malta', 'EUR', 'MT'),

-- CompanyAdmin - CYPRUSPLAY (Kıbrıs)
(2, 'Andreas', 'Georgiou', 'cyprus@nucleo.io', 'cyprus',
 '$argon2id$v=19$m=47104,t=1,p=1$/+pv+y99FW+8eHgBq9/RCg$ghMOBDkXj8OLGz8J9RF4m1xnrTm0o78HnG+Bkd2UJ+s',
 1, 'en', 'Asia/Nicosia', 'EUR', 'CY'),

-- CompanyAdmin - TURKBET (Türkiye)
(3, 'Ahmet', 'Yılmaz', 'turkbet@nucleo.io', 'turkbet',
 '$argon2id$v=19$m=47104,t=1,p=1$/+pv+y99FW+8eHgBq9/RCg$ghMOBDkXj8OLGz8J9RF4m1xnrTm0o78HnG+Bkd2UJ+s',
 1, 'tr', 'Europe/Istanbul', 'TRY', 'TR'),

-- TenantAdmin - eurobet_eu
(1, 'Maria', 'Santos', 'eurobet.eu@nucleo.io', 'eurobet_eu',
 '$argon2id$v=19$m=47104,t=1,p=1$/+pv+y99FW+8eHgBq9/RCg$ghMOBDkXj8OLGz8J9RF4m1xnrTm0o78HnG+Bkd2UJ+s',
 1, 'en', 'Europe/Malta', 'EUR', 'MT'),

-- TenantAdmin - cyprus_main
(2, 'Nikos', 'Papadopoulos', 'cyprus.admin@nucleo.io', 'cyprus_admin',
 '$argon2id$v=19$m=47104,t=1,p=1$/+pv+y99FW+8eHgBq9/RCg$ghMOBDkXj8OLGz8J9RF4m1xnrTm0o78HnG+Bkd2UJ+s',
 1, 'en', 'Asia/Nicosia', 'EUR', 'CY'),

-- TenantAdmin - turkbet_tr
(3, 'Mehmet', 'Demir', 'turkbet.admin@nucleo.io', 'turkbet_admin',
 '$argon2id$v=19$m=47104,t=1,p=1$/+pv+y99FW+8eHgBq9/RCg$ghMOBDkXj8OLGz8J9RF4m1xnrTm0o78HnG+Bkd2UJ+s',
 1, 'tr', 'Europe/Istanbul', 'TRY', 'TR'),

-- Moderator - turkbet_tr (multi-tenant test: 3 tenant, 3 farklı rol)
(3, 'Ayşe', 'Kaya', 'turkbet.mod@nucleo.io', 'turkbet_mod',
 '$argon2id$v=19$m=47104,t=1,p=1$/+pv+y99FW+8eHgBq9/RCg$ghMOBDkXj8OLGz8J9RF4m1xnrTm0o78HnG+Bkd2UJ+s',
 1, 'tr', 'Europe/Istanbul', 'TRY', 'TR'),

-- Editor - turkbet_tr
(3, 'Zeynep', 'Çelik', 'turkbet.edit@nucleo.io', 'turkbet_edit',
 '$argon2id$v=19$m=47104,t=1,p=1$/+pv+y99FW+8eHgBq9/RCg$ghMOBDkXj8OLGz8J9RF4m1xnrTm0o78HnG+Bkd2UJ+s',
 1, 'tr', 'Europe/Istanbul', 'TRY', 'TR'),

-- Operator - turkbet_tr
(3, 'Ali', 'Öztürk', 'turkbet.op@nucleo.io', 'turkbet_op',
 '$argon2id$v=19$m=47104,t=1,p=1$/+pv+y99FW+8eHgBq9/RCg$ghMOBDkXj8OLGz8J9RF4m1xnrTm0o78HnG+Bkd2UJ+s',
 1, 'tr', 'Europe/Istanbul', 'TRY', 'TR'),

-- User - eurobet_eu
(1, 'John', 'Smith', 'eurobet.user@nucleo.io', 'eurobet_user',
 '$argon2id$v=19$m=47104,t=1,p=1$/+pv+y99FW+8eHgBq9/RCg$ghMOBDkXj8OLGz8J9RF4m1xnrTm0o78HnG+Bkd2UJ+s',
 1, 'en', 'Europe/Malta', 'EUR', 'MT');

-- ================================================================
-- 6. COMPANY PASSWORD POLICY
-- ================================================================
-- NOT: Users tablosu dolduktan SONRA çalıştırılmalı (created_by FK)

-- Company ID 0 (Nucleo Platform) — 90 gün, son 5 şifre
INSERT INTO security.company_password_policy (company_id, expiry_days, history_count, created_by)
VALUES (0, 90, 5, 1);

-- Company ID 1 (EuroBet) — 30 gün, son 3 şifre
INSERT INTO security.company_password_policy (company_id, expiry_days, history_count, created_by)
VALUES (1, 30, 3, 1);

-- Company ID 2 (CyprusPlay) — policy yok, platform default kullanacak

-- Company ID 3 (TurkBet) — 60 gün, son 4 şifre
INSERT INTO security.company_password_policy (company_id, expiry_days, history_count, created_by)
VALUES (3, 60, 4, 1);

-- ================================================================
-- 7. GLOBAL ROL ATAMALARI (security.user_roles - tenant_id = NULL)
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
-- 8. TENANT ROL ATAMALARI (security.user_roles - tenant_id = değer)
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

-- turkbet.mod@nucleo.io → operator @ eurobet_eu (multi-tenant)
INSERT INTO security.user_roles (user_id, role_id, tenant_id)
SELECT u.id, r.id, t.id
FROM security.users u, security.roles r, core.tenants t
WHERE u.email = 'turkbet.mod@nucleo.io' AND r.code = 'operator' AND t.tenant_code = 'eurobet_eu';

-- turkbet.mod@nucleo.io → tenantadmin @ cyprus_main (multi-tenant)
INSERT INTO security.user_roles (user_id, role_id, tenant_id)
SELECT u.id, r.id, t.id
FROM security.users u, security.roles r, core.tenants t
WHERE u.email = 'turkbet.mod@nucleo.io' AND r.code = 'tenantadmin' AND t.tenant_code = 'cyprus_main';

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
-- 9. TENANT ERİŞİM İZİNLERİ (security.user_allowed_tenants)
-- ================================================================
-- Sadece tenant-level kullanıcılar için.
-- Platform (superadmin, admin) bypass eder, company admin company üzerinden erişir.

-- eurobet.eu@nucleo.io → eurobet_eu
INSERT INTO security.user_allowed_tenants (user_id, tenant_id)
SELECT u.id, t.id FROM security.users u, core.tenants t
WHERE u.email = 'eurobet.eu@nucleo.io' AND t.tenant_code = 'eurobet_eu';

-- cyprus.admin@nucleo.io → cyprus_main
INSERT INTO security.user_allowed_tenants (user_id, tenant_id)
SELECT u.id, t.id FROM security.users u, core.tenants t
WHERE u.email = 'cyprus.admin@nucleo.io' AND t.tenant_code = 'cyprus_main';

-- turkbet.admin@nucleo.io → turkbet_tr
INSERT INTO security.user_allowed_tenants (user_id, tenant_id)
SELECT u.id, t.id FROM security.users u, core.tenants t
WHERE u.email = 'turkbet.admin@nucleo.io' AND t.tenant_code = 'turkbet_tr';

-- turkbet.mod@nucleo.io → turkbet_tr + eurobet_eu + cyprus_main (multi-tenant)
INSERT INTO security.user_allowed_tenants (user_id, tenant_id)
SELECT u.id, t.id FROM security.users u, core.tenants t
WHERE u.email = 'turkbet.mod@nucleo.io' AND t.tenant_code = 'turkbet_tr';

INSERT INTO security.user_allowed_tenants (user_id, tenant_id)
SELECT u.id, t.id FROM security.users u, core.tenants t
WHERE u.email = 'turkbet.mod@nucleo.io' AND t.tenant_code = 'eurobet_eu';

INSERT INTO security.user_allowed_tenants (user_id, tenant_id)
SELECT u.id, t.id FROM security.users u, core.tenants t
WHERE u.email = 'turkbet.mod@nucleo.io' AND t.tenant_code = 'cyprus_main';

-- turkbet.edit@nucleo.io → turkbet_tr
INSERT INTO security.user_allowed_tenants (user_id, tenant_id)
SELECT u.id, t.id FROM security.users u, core.tenants t
WHERE u.email = 'turkbet.edit@nucleo.io' AND t.tenant_code = 'turkbet_tr';

-- turkbet.op@nucleo.io → turkbet_tr
INSERT INTO security.user_allowed_tenants (user_id, tenant_id)
SELECT u.id, t.id FROM security.users u, core.tenants t
WHERE u.email = 'turkbet.op@nucleo.io' AND t.tenant_code = 'turkbet_tr';

-- eurobet.user@nucleo.io → eurobet_eu
INSERT INTO security.user_allowed_tenants (user_id, tenant_id)
SELECT u.id, t.id FROM security.users u, core.tenants t
WHERE u.email = 'eurobet.user@nucleo.io' AND t.tenant_code = 'eurobet_eu';

-- ================================================================
-- 10. TENANT PARA BİRİMLERİ (11)
-- ================================================================

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

-- ================================================================
-- 11. TENANT KRİPTO PARA BİRİMLERİ (9)
-- ================================================================

INSERT INTO core.tenant_cryptocurrencies (tenant_id, symbol, is_enabled)
SELECT t.id, c.symbol, true FROM core.tenants t
CROSS JOIN (VALUES ('BTC'), ('ETH'), ('SOL')) AS c(symbol)
WHERE t.tenant_code = 'eurobet_eu';

INSERT INTO core.tenant_cryptocurrencies (tenant_id, symbol, is_enabled)
SELECT t.id, c.symbol, true FROM core.tenants t
CROSS JOIN (VALUES ('BTC'), ('ETH')) AS c(symbol)
WHERE t.tenant_code = 'eurobet_uk';

INSERT INTO core.tenant_cryptocurrencies (tenant_id, symbol, is_enabled)
SELECT t.id, c.symbol, true FROM core.tenants t
CROSS JOIN (VALUES ('BTC'), ('ETH')) AS c(symbol)
WHERE t.tenant_code = 'cyprus_main';

INSERT INTO core.tenant_cryptocurrencies (tenant_id, symbol, is_enabled)
SELECT t.id, c.symbol, true FROM core.tenants t
CROSS JOIN (VALUES ('BTC'), ('SOL')) AS c(symbol)
WHERE t.tenant_code = 'turkbet_tr';

-- ================================================================
-- 12. TENANT DİLLERİ (8 — 4 tenant × 2 dil)
-- ================================================================

INSERT INTO core.tenant_languages (tenant_id, language_code, is_enabled)
SELECT t.id, l.code, true FROM core.tenants t
CROSS JOIN (VALUES ('en'), ('tr')) AS l(code);

-- ================================================================
-- 13. TENANT JURISDICTIONS (4)
-- ================================================================

-- eurobet_eu → MGA (primary) + UKGC
INSERT INTO core.tenant_jurisdictions (tenant_id, jurisdiction_id, license_number, license_issued_at, license_expires_at, is_primary, status)
SELECT t.id, j.id, 'MGA/B2C/123/2024', '2024-01-01', '2029-01-01', TRUE, 'active'
FROM core.tenants t, catalog.jurisdictions j
WHERE t.tenant_code = 'eurobet_eu' AND j.code = 'MGA';

INSERT INTO core.tenant_jurisdictions (tenant_id, jurisdiction_id, license_number, license_issued_at, license_expires_at, is_primary, status)
SELECT t.id, j.id, 'GC-000123-R-123456', '2024-01-01', '2029-01-01', FALSE, 'active'
FROM core.tenants t, catalog.jurisdictions j
WHERE t.tenant_code = 'eurobet_eu' AND j.code = 'UKGC';

-- cyprus_main → CUR
INSERT INTO core.tenant_jurisdictions (tenant_id, jurisdiction_id, license_number, license_issued_at, license_expires_at, is_primary, status)
SELECT t.id, j.id, 'CEG/1234/2024', '2024-01-01', '2025-01-01', TRUE, 'active'
FROM core.tenants t, catalog.jurisdictions j
WHERE t.tenant_code = 'cyprus_main' AND j.code = 'CUR';

-- turkbet_tr → CUR
INSERT INTO core.tenant_jurisdictions (tenant_id, jurisdiction_id, license_number, license_issued_at, license_expires_at, is_primary, status)
SELECT t.id, j.id, 'CEG/5678/2024', '2024-01-01', '2025-01-01', TRUE, 'active'
FROM core.tenants t, catalog.jurisdictions j
WHERE t.tenant_code = 'turkbet_tr' AND j.code = 'CUR';

-- ================================================================
-- 14. TENANT AYARLARI (40 — 4 tenant × 10 setting)
-- ================================================================

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

-- Tenant Ana DB Bağlantısı (tenant_{id})
INSERT INTO core.tenant_settings (tenant_id, category, setting_key, setting_value, description)
SELECT t.id, 'Database', 'connection_tenant',
    format('{"host": "207.180.241.230", "port": 5433, "database": "tenant_%s", "username": "postgres", "password": "NucleoPostgres2026", "ssl_mode": "prefer", "min_pool_size": 5, "max_pool_size": 50, "connection_timeout": 30, "command_timeout": 60, "replica_enabled": true, "replica_port": 5434, "replica_min_pool_size": 2, "replica_max_pool_size": 10}', t.id)::jsonb,
    'Tenant main database connection settings'
FROM core.tenants t;

-- Tenant Audit DB Bağlantısı (tenant_audit_{id})
INSERT INTO core.tenant_settings (tenant_id, category, setting_key, setting_value, description)
SELECT t.id, 'Database', 'connection_tenant_audit',
    format('{"host": "207.180.241.230", "port": 5433, "database": "tenant_audit_%s", "username": "postgres", "password": "NucleoPostgres2026", "ssl_mode": "prefer", "min_pool_size": 2, "max_pool_size": 20, "connection_timeout": 30, "command_timeout": 60, "replica_enabled": true, "replica_port": 5434, "replica_min_pool_size": 1, "replica_max_pool_size": 5}', t.id)::jsonb,
    'Tenant audit database connection settings'
FROM core.tenants t;

-- Tenant Log DB Bağlantısı (tenant_log_{id})
INSERT INTO core.tenant_settings (tenant_id, category, setting_key, setting_value, description)
SELECT t.id, 'Database', 'connection_tenant_log',
    format('{"host": "207.180.241.230", "port": 5433, "database": "tenant_log_%s", "username": "postgres", "password": "NucleoPostgres2026", "ssl_mode": "prefer", "min_pool_size": 2, "max_pool_size": 30, "connection_timeout": 30, "command_timeout": 60, "replica_enabled": true, "replica_port": 5434, "replica_min_pool_size": 1, "replica_max_pool_size": 5}', t.id)::jsonb,
    'Tenant log database connection settings'
FROM core.tenants t;

-- Tenant Affiliate DB Bağlantısı (tenant_affiliate_{id})
INSERT INTO core.tenant_settings (tenant_id, category, setting_key, setting_value, description)
SELECT t.id, 'Database', 'connection_tenant_affiliate',
    format('{"host": "207.180.241.230", "port": 5433, "database": "tenant_affiliate_%s", "username": "postgres", "password": "NucleoPostgres2026", "ssl_mode": "prefer", "min_pool_size": 2, "max_pool_size": 20, "connection_timeout": 30, "command_timeout": 60, "replica_enabled": true, "replica_port": 5434, "replica_min_pool_size": 1, "replica_max_pool_size": 5}', t.id)::jsonb,
    'Tenant affiliate database connection settings'
FROM core.tenants t;

-- Tenant Report DB Bağlantısı (tenant_report_{id})
INSERT INTO core.tenant_settings (tenant_id, category, setting_key, setting_value, description)
SELECT t.id, 'Database', 'connection_tenant_report',
    format('{"host": "207.180.241.230", "port": 5433, "database": "tenant_report_%s", "username": "postgres", "password": "NucleoPostgres2026", "ssl_mode": "prefer", "min_pool_size": 2, "max_pool_size": 30, "connection_timeout": 30, "command_timeout": 120, "replica_enabled": true, "replica_port": 5434, "replica_min_pool_size": 2, "replica_max_pool_size": 15}', t.id)::jsonb,
    'Tenant report database connection settings (replica enabled for heavy queries)'
FROM core.tenants t;

-- Password Policy Ayarları
INSERT INTO core.tenant_settings (tenant_id, category, setting_key, setting_value, description)
SELECT t.id, 'Security', 'password_expiry_days',
    '30'::jsonb,
    'Player password expiry period in days (0 = never expires)'
FROM core.tenants t;

INSERT INTO core.tenant_settings (tenant_id, category, setting_key, setting_value, description)
SELECT t.id, 'Security', 'password_history_count',
    '3'::jsonb,
    'Number of previous passwords to check for reuse prevention'
FROM core.tenants t;

INSERT INTO core.tenant_settings (tenant_id, category, setting_key, setting_value, description)
SELECT t.id, 'Security', 'password_min_length',
    '8'::jsonb,
    'Minimum password length requirement'
FROM core.tenants t;

-- Silo Placement Ayarlari (Tenant Cluster grain placement)
INSERT INTO core.tenant_settings (tenant_id, category, setting_key, setting_value, description)
SELECT t.id, 'Infrastructure', 'silo_placement',
    '"general"'::jsonb,
    'Silo placement pool assignment (general, dedicated-1, shared-2-3, etc.)'
FROM core.tenants t;

-- Dedicated Redis Bağlantıları (sadece shared olmayan tenant'lar)
-- eurobet_uk → 207.180.241.193:7003
INSERT INTO core.tenant_settings (tenant_id, category, setting_key, setting_value, description)
SELECT t.id, 'Infrastructure', 'redis_connection',
    '"207.180.241.193:7003"'::jsonb,
    'Dedicated Redis connection string'
FROM core.tenants t WHERE t.tenant_code = 'eurobet_uk';

INSERT INTO core.tenant_settings (tenant_id, category, setting_key, setting_value, description)
SELECT t.id, 'Infrastructure', 'redis_password',
    '"NucleoRedis2026!"'::jsonb,
    'Dedicated Redis password'
FROM core.tenants t WHERE t.tenant_code = 'eurobet_uk';

-- cyprus_main → 207.180.241.142:7003
INSERT INTO core.tenant_settings (tenant_id, category, setting_key, setting_value, description)
SELECT t.id, 'Infrastructure', 'redis_connection',
    '"207.180.241.142:7003"'::jsonb,
    'Dedicated Redis connection string'
FROM core.tenants t WHERE t.tenant_code = 'cyprus_main';

INSERT INTO core.tenant_settings (tenant_id, category, setting_key, setting_value, description)
SELECT t.id, 'Infrastructure', 'redis_password',
    '"NucleoRedis2026!"'::jsonb,
    'Dedicated Redis password'
FROM core.tenants t WHERE t.tenant_code = 'cyprus_main';

-- ================================================================
-- 15. JURISDICTIONS & KYC COMPLIANCE DATA
-- ================================================================
-- Bu bölüm staging_seed.sql'den birebir kopyalanmıştır (değişiklik yok).

-- ================================================================
-- 15.1 JURISDICTIONS (12 — Lisans Otoriteleri)
-- ================================================================
INSERT INTO catalog.jurisdictions (id, code, name, country_code, region, authority_type, website_url, license_prefix, is_active) VALUES
-- Tier 1 - Strict Regulators
(1, 'MGA', 'Malta Gaming Authority', 'MT', NULL, 'national', 'https://www.mga.org.mt', 'MGA/B2C/', TRUE),
(2, 'UKGC', 'UK Gambling Commission', 'GB', NULL, 'national', 'https://www.gamblingcommission.gov.uk', 'GC-', TRUE),
(3, 'GGL', 'Gemeinsame Glücksspielbehörde der Länder', 'DE', NULL, 'national', 'https://www.ggl-behoerde.de', 'GGL-', TRUE),

-- Tier 2 - Moderate Regulators
(4, 'SGA', 'Swedish Gambling Authority', 'SE', NULL, 'national', 'https://www.spelinspektionen.se', 'SGA-', TRUE),
(5, 'DGA', 'Danish Gambling Authority', 'DK', NULL, 'national', 'https://www.spillemyndigheden.dk', 'DGA-', TRUE),
(6, 'AGCO', 'Alcohol and Gaming Commission of Ontario', 'CA', 'Ontario', 'regional', 'https://www.agco.ca', 'iGO-', TRUE),

-- Tier 3 - Offshore/Flexible
(7, 'CUR', 'Curacao eGaming', 'CW', NULL, 'offshore', 'https://www.curacao-egaming.com', 'CEG/', TRUE),
(8, 'GIB', 'Gibraltar Gambling Commissioner', 'GI', NULL, 'offshore', 'https://www.gibraltar.gov.gi/gambling', 'RGL/', TRUE),
(9, 'IOM', 'Isle of Man Gambling Supervision Commission', 'IM', NULL, 'offshore', 'https://www.gov.im/gambling', 'GSC/', TRUE),

-- Special Markets
(10, 'ONJN', 'Romanian National Gambling Office', 'RO', NULL, 'national', 'https://www.onjn.gov.ro', 'ONJN-', TRUE),
(11, 'ADM', 'Agenzia delle Dogane e dei Monopoli', 'IT', NULL, 'national', 'https://www.adm.gov.it', 'ADM/', TRUE),
(12, 'DGOJ', 'Dirección General de Ordenación del Juego', 'ES', NULL, 'national', 'https://www.ordenacionjuego.es', 'DGOJ-', TRUE);

-- ================================================================
-- 15.2 KYC POLICIES (12 — Her Jurisdiction için)
-- ================================================================
INSERT INTO catalog.kyc_policies (jurisdiction_id, verification_timing, verification_deadline_hours, grace_period_hours,
    edd_deposit_threshold, edd_withdrawal_threshold, edd_cumulative_threshold, edd_threshold_currency,
    min_age, age_verification_required, address_verification_required, address_document_max_age_days,
    sof_threshold, sof_required_above_threshold, pep_screening_required, sanctions_screening_required, is_active) VALUES

-- MGA (Malta) - 72 saat grace period
(1, 'after_registration', 72, 72, 2000.00, 2000.00, 10000.00, 'EUR', 18, TRUE, TRUE, 90, 15000.00, TRUE, TRUE, TRUE, TRUE),

-- UKGC (UK) - Kayıt öncesi zorunlu
(2, 'before_registration', NULL, 0, 2000.00, 2000.00, 5000.00, 'GBP', 18, TRUE, TRUE, 90, 10000.00, TRUE, TRUE, TRUE, TRUE),

-- GGL (Germany) - Strict, kayıt öncesi
(3, 'before_registration', NULL, 0, 1000.00, 1000.00, 1000.00, 'EUR', 18, TRUE, TRUE, 90, 5000.00, TRUE, TRUE, TRUE, TRUE),

-- SGA (Sweden)
(4, 'before_deposit', 24, 0, 5000.00, 5000.00, 20000.00, 'SEK', 18, TRUE, TRUE, 90, 50000.00, TRUE, TRUE, TRUE, TRUE),

-- DGA (Denmark)
(5, 'before_deposit', 24, 0, 10000.00, 10000.00, 50000.00, 'DKK', 18, TRUE, TRUE, 90, 100000.00, TRUE, TRUE, TRUE, TRUE),

-- AGCO (Ontario)
(6, 'before_deposit', 24, 0, 3000.00, 3000.00, 10000.00, 'CAD', 19, TRUE, TRUE, 90, 25000.00, TRUE, TRUE, TRUE, TRUE),

-- Curacao - Flexible
(7, 'before_withdrawal', NULL, 0, 5000.00, 2000.00, 10000.00, 'EUR', 18, TRUE, FALSE, 180, 25000.00, FALSE, TRUE, TRUE, TRUE),

-- Gibraltar
(8, 'before_withdrawal', 72, 24, 3000.00, 2000.00, 15000.00, 'EUR', 18, TRUE, TRUE, 90, 20000.00, TRUE, TRUE, TRUE, TRUE),

-- Isle of Man
(9, 'before_withdrawal', 72, 24, 3000.00, 2000.00, 15000.00, 'GBP', 18, TRUE, TRUE, 90, 20000.00, TRUE, TRUE, TRUE, TRUE),

-- Romania
(10, 'before_deposit', 24, 0, 2000.00, 2000.00, 10000.00, 'RON', 18, TRUE, TRUE, 90, 50000.00, TRUE, TRUE, TRUE, TRUE),

-- Italy
(11, 'before_registration', NULL, 0, 1000.00, 1000.00, 5000.00, 'EUR', 18, TRUE, TRUE, 90, 10000.00, TRUE, TRUE, TRUE, TRUE),

-- Spain
(12, 'before_deposit', 24, 0, 3000.00, 3000.00, 15000.00, 'EUR', 18, TRUE, TRUE, 90, 10000.00, TRUE, TRUE, TRUE, TRUE);

-- ================================================================
-- 15.3 KYC DOCUMENT REQUIREMENTS (10)
-- ================================================================
-- MGA (Malta)
INSERT INTO catalog.kyc_document_requirements (jurisdiction_id, document_type, accepted_subtypes, is_required, required_for, max_document_age_days, expires_after_days, verification_method, display_order) VALUES
(1, 'identity', '["passport", "national_id", "driving_license"]', TRUE, 'all', NULL, 365, 'hybrid', 1),
(1, 'proof_of_address', '["utility_bill", "bank_statement", "government_letter"]', TRUE, 'all', 90, 180, 'hybrid', 2),
(1, 'selfie', '["selfie_with_id", "liveness_check"]', TRUE, 'all', NULL, 365, 'automated', 3),
(1, 'source_of_funds', '["payslip", "tax_return", "bank_statement"]', FALSE, 'edd', 90, 180, 'manual', 4),

-- UKGC (UK)
(2, 'identity', '["passport", "driving_license"]', TRUE, 'all', NULL, 365, 'automated', 1),
(2, 'proof_of_address', '["utility_bill", "bank_statement", "council_tax"]', TRUE, 'all', 90, 180, 'automated', 2),
(2, 'selfie', '["liveness_check"]', TRUE, 'all', NULL, 365, 'automated', 3),
(2, 'source_of_funds', '["payslip", "p60", "bank_statement", "pension_statement"]', TRUE, 'edd', 90, 180, 'manual', 4),

-- GGL (Germany)
(3, 'identity', '["personalausweis", "passport"]', TRUE, 'all', NULL, NULL, 'automated', 1),
(3, 'proof_of_address', '["meldebescheinigung", "utility_bill"]', TRUE, 'all', 90, 180, 'hybrid', 2),
(3, 'bank_statement', '["bank_account_verification"]', TRUE, 'deposit', NULL, 365, 'automated', 3),

-- Curacao (Flexible)
(7, 'identity', '["passport", "national_id", "driving_license"]', TRUE, 'withdrawal', NULL, 730, 'manual', 1),
(7, 'proof_of_address', '["utility_bill", "bank_statement"]', FALSE, 'edd', 180, 365, 'manual', 2),
(7, 'selfie', '["selfie_with_id"]', TRUE, 'withdrawal', NULL, 730, 'manual', 3);

-- ================================================================
-- 15.4 KYC LEVEL REQUIREMENTS (9)
-- ================================================================
-- MGA Levels
INSERT INTO catalog.kyc_level_requirements (jurisdiction_id, kyc_level,
    trigger_cumulative_deposit, trigger_cumulative_withdrawal, trigger_single_deposit, trigger_single_withdrawal,
    trigger_days_since_registration, trigger_on_first_withdrawal,
    max_single_deposit, max_single_withdrawal, max_daily_deposit, max_daily_withdrawal, max_monthly_deposit, max_monthly_withdrawal,
    required_documents, required_verifications, verification_deadline_hours, grace_period_hours, on_deadline_action, level_order, is_active) VALUES
-- MGA basic
(1, 'basic', NULL, NULL, NULL, NULL, NULL, FALSE,
    200.00, 0, 500.00, 0, 2000.00, 0,
    '["email", "phone"]', '["email_verified", "phone_verified"]',
    72, 72, 'block_deposits', 0, TRUE),
-- MGA standard
(1, 'standard', 2000.00, NULL, 500.00, NULL, 30, TRUE,
    5000.00, 10000.00, 10000.00, 10000.00, 50000.00, 50000.00,
    '["identity", "proof_of_address", "selfie"]', '["email_verified", "phone_verified", "pep_check", "sanctions_check"]',
    72, 24, 'block_all', 1, TRUE),
-- MGA enhanced
(1, 'enhanced', 10000.00, 10000.00, 5000.00, 5000.00, NULL, FALSE,
    50000.00, 50000.00, 100000.00, 100000.00, 500000.00, 500000.00,
    '["identity", "proof_of_address", "selfie", "source_of_funds"]', '["email_verified", "phone_verified", "pep_check", "sanctions_check", "sof_verified"]',
    NULL, 0, 'block_all', 2, TRUE),

-- UKGC Levels (Stricter)
(2, 'basic', NULL, NULL, NULL, NULL, NULL, FALSE,
    0, 0, 0, 0, 0, 0,
    '[]', '["age_verified", "identity_verified"]',
    NULL, 0, 'block_all', 0, TRUE),
(2, 'standard', 500.00, NULL, 250.00, NULL, NULL, TRUE,
    2000.00, 5000.00, 5000.00, 5000.00, 20000.00, 20000.00,
    '["identity", "proof_of_address", "selfie"]', '["age_verified", "identity_verified", "address_verified", "pep_check", "sanctions_check"]',
    24, 0, 'block_all', 1, TRUE),
(2, 'enhanced', 5000.00, 5000.00, 2000.00, 2000.00, NULL, FALSE,
    25000.00, 25000.00, 50000.00, 50000.00, 200000.00, 200000.00,
    '["identity", "proof_of_address", "selfie", "source_of_funds"]', '["age_verified", "identity_verified", "address_verified", "pep_check", "sanctions_check", "sof_verified", "enhanced_monitoring"]',
    48, 0, 'suspend_account', 2, TRUE),

-- Curacao Levels (Flexible)
(7, 'basic', NULL, NULL, NULL, NULL, NULL, FALSE,
    5000.00, 0, 10000.00, 0, 50000.00, 0,
    '["email"]', '["email_verified"]',
    NULL, 0, 'block_withdrawals', 0, TRUE),
(7, 'standard', NULL, 2000.00, NULL, 1000.00, NULL, TRUE,
    10000.00, 10000.00, 25000.00, 25000.00, 100000.00, 100000.00,
    '["identity", "selfie"]', '["email_verified", "identity_verified", "sanctions_check"]',
    168, 0, 'block_withdrawals', 1, TRUE),
(7, 'enhanced', 25000.00, 10000.00, 10000.00, 5000.00, NULL, FALSE,
    100000.00, 100000.00, 250000.00, 250000.00, 1000000.00, 1000000.00,
    '["identity", "proof_of_address", "selfie", "source_of_funds"]', '["email_verified", "identity_verified", "address_verified", "pep_check", "sanctions_check", "sof_verified"]',
    336, 0, 'block_all', 2, TRUE);

-- ================================================================
-- 15.5 RESPONSIBLE GAMING POLICIES (4)
-- ================================================================
INSERT INTO catalog.responsible_gaming_policies (jurisdiction_id,
    deposit_limit_required, deposit_limit_options, deposit_limit_max_increase_wait_hours,
    loss_limit_required, loss_limit_options,
    session_limit_required, session_limit_max_hours, session_break_required, session_break_after_hours, session_break_duration_minutes,
    reality_check_required, reality_check_interval_minutes,
    cooling_off_available, cooling_off_min_days, cooling_off_max_days, cooling_off_revocable,
    self_exclusion_available, self_exclusion_min_months, self_exclusion_permanent_option, self_exclusion_revocable,
    central_exclusion_system, central_exclusion_integration_required,
    credit_card_gambling_allowed, crypto_payments_allowed, payment_method_ownership_verification, is_active) VALUES

-- MGA
(1, TRUE, '["daily", "weekly", "monthly"]', 24,
    TRUE, '["daily", "weekly", "monthly"]',
    TRUE, 24, FALSE, NULL, NULL,
    TRUE, 60,
    TRUE, 1, 42, FALSE,
    TRUE, 6, TRUE, FALSE,
    NULL, FALSE,
    TRUE, TRUE, TRUE, TRUE),

-- UKGC (Very strict)
(2, TRUE, '["daily", "weekly", "monthly"]', 24,
    TRUE, '["daily", "weekly", "monthly"]',
    TRUE, 12, TRUE, 1, 5,
    TRUE, 30,
    TRUE, 1, 42, FALSE,
    TRUE, 6, TRUE, FALSE,
    'GAMSTOP', TRUE,
    FALSE, FALSE, TRUE, TRUE),

-- GGL (Germany - Strictest)
(3, TRUE, '["monthly"]', 168,
    TRUE, '["monthly"]',
    TRUE, 1, TRUE, 1, 5,
    TRUE, 60,
    TRUE, 7, 90, FALSE,
    TRUE, 12, TRUE, FALSE,
    'OASIS', TRUE,
    FALSE, FALSE, TRUE, TRUE),

-- Curacao (Flexible)
(7, FALSE, '["daily", "weekly", "monthly"]', 0,
    FALSE, '["daily", "weekly", "monthly"]',
    FALSE, NULL, FALSE, NULL, NULL,
    FALSE, NULL,
    TRUE, 1, 30, TRUE,
    TRUE, 6, TRUE, TRUE,
    NULL, FALSE,
    TRUE, TRUE, FALSE, TRUE);

-- ================================================================
-- 16. SEQUENCE RESET'LER
-- ================================================================

SELECT setval('core.companies_id_seq', COALESCE((SELECT MAX(id) FROM core.companies), 0) + 1, false);
SELECT setval('core.tenants_id_seq', COALESCE((SELECT MAX(id) FROM core.tenants), 0) + 1, false);
SELECT setval('catalog.jurisdictions_id_seq', COALESCE((SELECT MAX(id) FROM catalog.jurisdictions), 0) + 1, false);

-- ================================================================
-- 17. DOĞRULAMA
-- ================================================================

-- Blok 1: Ana Veriler
DO $$
DECLARE
    v_companies INT; v_roles INT; v_tenants INT; v_users INT;
    v_global_roles INT; v_tenant_roles INT; v_tenant_access INT;
    v_password_policies INT; v_currencies INT; v_cryptocurrencies INT;
    v_languages INT; v_settings INT;
BEGIN
    SELECT COUNT(*) INTO v_companies FROM core.companies;
    SELECT COUNT(*) INTO v_roles FROM security.roles;
    SELECT COUNT(*) INTO v_tenants FROM core.tenants;
    SELECT COUNT(*) INTO v_users FROM security.users;
    SELECT COUNT(*) INTO v_global_roles FROM security.user_roles WHERE tenant_id IS NULL;
    SELECT COUNT(*) INTO v_tenant_roles FROM security.user_roles WHERE tenant_id IS NOT NULL;
    SELECT COUNT(*) INTO v_tenant_access FROM security.user_allowed_tenants;
    SELECT COUNT(*) INTO v_password_policies FROM security.company_password_policy;
    SELECT COUNT(*) INTO v_currencies FROM core.tenant_currencies;
    SELECT COUNT(*) INTO v_cryptocurrencies FROM core.tenant_cryptocurrencies;
    SELECT COUNT(*) INTO v_languages FROM core.tenant_languages;
    SELECT COUNT(*) INTO v_settings FROM core.tenant_settings;

    RAISE NOTICE '================================================';
    RAISE NOTICE 'SEED TEST DATA — ANA VERİLER';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Companies: % (beklenen: 4)', v_companies;
    RAISE NOTICE 'Roles: % (beklenen: 8)', v_roles;
    RAISE NOTICE 'Tenants: % (beklenen: 4)', v_tenants;
    RAISE NOTICE 'Users: % (beklenen: 12)', v_users;
    RAISE NOTICE 'Global Role Assignments: % (beklenen: 5)', v_global_roles;
    RAISE NOTICE 'Tenant Role Assignments: % (beklenen: 9)', v_tenant_roles;
    RAISE NOTICE 'Tenant Access: % (beklenen: 9)', v_tenant_access;
    RAISE NOTICE 'Company Password Policies: % (beklenen: 3)', v_password_policies;
    RAISE NOTICE 'Tenant Currencies: % (beklenen: 11)', v_currencies;
    RAISE NOTICE 'Tenant Cryptocurrencies: % (beklenen: 9)', v_cryptocurrencies;
    RAISE NOTICE 'Tenant Languages: % (beklenen: 8)', v_languages;
    RAISE NOTICE 'Tenant Settings: % (beklenen: 48)', v_settings;
    RAISE NOTICE '================================================';
END $$;

-- Blok 2: Compliance
DO $$
DECLARE
    v_jurisdictions INT; v_kyc_policies INT; v_doc_reqs INT;
    v_level_reqs INT; v_rg_policies INT; v_tenant_j INT;
BEGIN
    SELECT COUNT(*) INTO v_jurisdictions FROM catalog.jurisdictions;
    SELECT COUNT(*) INTO v_kyc_policies FROM catalog.kyc_policies;
    SELECT COUNT(*) INTO v_doc_reqs FROM catalog.kyc_document_requirements;
    SELECT COUNT(*) INTO v_level_reqs FROM catalog.kyc_level_requirements;
    SELECT COUNT(*) INTO v_rg_policies FROM catalog.responsible_gaming_policies;
    SELECT COUNT(*) INTO v_tenant_j FROM core.tenant_jurisdictions;

    RAISE NOTICE '================================================';
    RAISE NOTICE 'SEED TEST DATA — COMPLIANCE';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Jurisdictions: % (beklenen: 12)', v_jurisdictions;
    RAISE NOTICE 'KYC Policies: % (beklenen: 12)', v_kyc_policies;
    RAISE NOTICE 'Document Requirements: % (beklenen: 10)', v_doc_reqs;
    RAISE NOTICE 'Level Requirements: % (beklenen: 9)', v_level_reqs;
    RAISE NOTICE 'Responsible Gaming Policies: % (beklenen: 4)', v_rg_policies;
    RAISE NOTICE 'Tenant Jurisdictions: % (beklenen: 4)', v_tenant_j;
    RAISE NOTICE '================================================';
END $$;

-- ================================================================
-- TEST KULLANICILARI ÖZETİ
-- ================================================================
--
-- | #  | Email                   | Company     | Global Rol   | Tenant Rolleri                                              |
-- |----|-------------------------|-------------|--------------|-------------------------------------------------------------|
-- | 1  | superadmin@nucleo.io    | NUCLEO      | superadmin   | —                                                           |
-- | 2  | admin@nucleo.io         | NUCLEO      | admin        | —                                                           |
-- | 3  | eurobet@nucleo.io       | EUROBET     | companyadmin | —                                                           |
-- | 4  | cyprus@nucleo.io        | CYPRUSPLAY  | companyadmin | —                                                           |
-- | 5  | turkbet@nucleo.io       | TURKBET     | companyadmin | —                                                           |
-- | 6  | eurobet.eu@nucleo.io    | EUROBET     | —            | tenantadmin@eurobet_eu                                      |
-- | 7  | cyprus.admin@nucleo.io  | CYPRUSPLAY  | —            | tenantadmin@cyprus_main                                     |
-- | 8  | turkbet.admin@nucleo.io | TURKBET     | —            | tenantadmin@turkbet_tr                                      |
-- | 9  | turkbet.mod@nucleo.io   | TURKBET     | —            | moderator@turkbet_tr, operator@eurobet_eu, tenantadmin@cyprus_main |
-- | 10 | turkbet.edit@nucleo.io  | TURKBET     | —            | editor@turkbet_tr                                           |
-- | 11 | turkbet.op@nucleo.io    | TURKBET     | —            | operator@turkbet_tr                                         |
-- | 12 | eurobet.user@nucleo.io  | EUROBET     | —            | user@eurobet_eu                                             |
--
-- Tüm şifreler: deneme
-- ================================================================
