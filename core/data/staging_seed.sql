-- ================================================================
-- SORTIS ONE - TEST SEED DATA
-- ================================================================
-- Staging ve development ortamları için test verileri.
-- Companies, roles, clients, users, settings, compliance.
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
TRUNCATE TABLE security.user_allowed_clients RESTART IDENTITY CASCADE;
TRUNCATE TABLE security.user_roles RESTART IDENTITY CASCADE;
TRUNCATE TABLE security.users RESTART IDENTITY CASCADE;
TRUNCATE TABLE security.roles RESTART IDENTITY CASCADE;

-- Core
TRUNCATE TABLE core.client_jurisdictions RESTART IDENTITY CASCADE;
TRUNCATE TABLE core.client_settings RESTART IDENTITY CASCADE;
TRUNCATE TABLE core.client_languages RESTART IDENTITY CASCADE;
TRUNCATE TABLE core.client_currencies RESTART IDENTITY CASCADE;
TRUNCATE TABLE core.client_cryptocurrencies RESTART IDENTITY CASCADE;
TRUNCATE TABLE core.clients RESTART IDENTITY CASCADE;
TRUNCATE TABLE core.companies RESTART IDENTITY CASCADE;

-- Compliance/Catalog
TRUNCATE TABLE catalog.responsible_gaming_policies RESTART IDENTITY CASCADE;
TRUNCATE TABLE catalog.kyc_level_requirements RESTART IDENTITY CASCADE;
TRUNCATE TABLE catalog.kyc_document_requirements RESTART IDENTITY CASCADE;
TRUNCATE TABLE catalog.kyc_policies RESTART IDENTITY CASCADE;
TRUNCATE TABLE catalog.jurisdictions RESTART IDENTITY CASCADE;

-- Sequence reset
SELECT setval('core.companies_id_seq', 1, false);
SELECT setval('core.clients_id_seq', 1, false);

-- ================================================================
-- 2. COMPANIES (4)
-- ================================================================

INSERT INTO core.companies (id, company_code, company_name, status, country_code, timezone) VALUES
(0, 'SORTIS', 'Sortis One Platform', 1, 'TR', 'Europe/Istanbul'),
(1, 'EUROBET', 'EuroBet Gaming Ltd', 1, 'MT', 'Europe/Malta'),
(2, 'CYPRUSPLAY', 'CyprusPlay Entertainment', 1, 'CY', 'Asia/Nicosia'),
(3, 'TURKBET', 'TurkBet Oyun Teknolojileri', 1, 'TR', 'Europe/Istanbul');

SELECT setval('core.companies_id_seq', (SELECT MAX(id) FROM core.companies) + 1);

-- ================================================================
-- 3. ROLES (8)
-- ================================================================
-- Hierarchy: superadmin > admin > companyadmin > clientadmin > moderator > editor > operator > user

INSERT INTO security.roles (code, name, description, level, status, is_platform_role) VALUES
('superadmin', 'Super Admin', 'Platform sahibi - Tüm yetkiler', 100, 1, TRUE),
('admin', 'Admin', 'Sistem yöneticisi - Tüm company ve client işlemleri', 90, 1, TRUE),
('companyadmin', 'Company Admin', 'Şirket yöneticisi - Kendi company altındaki client işlemleri', 80, 1, FALSE),
('clientadmin', 'Client Admin', 'Client yöneticisi - Kendi client içindeki işlemler', 70, 1, FALSE),
('moderator', 'Moderator', 'İçerik moderatörü - Player düzenleme yetkisi', 60, 1, FALSE),
('editor', 'Editor', 'İçerik editörü - Banner, slider, içerik yönetimi', 50, 1, FALSE),
('operator', 'Operator', 'Müşteri hizmetleri - Player görüntüleme ve KYC', 40, 1, FALSE),
('user', 'User', 'Standart kullanıcı - Sadece görüntüleme', 10, 1, FALSE);

-- ================================================================
-- 4. CLIENTS (4)
-- ================================================================

INSERT INTO core.clients (company_id, client_code, client_name, environment, base_currency, default_language, default_country, timezone, status) VALUES
-- EUROBET (Malta) - 2 client
(1, 'eurobet_eu', 'EuroBet Europe', 'prod', 'EUR', 'en', 'MT', 'Europe/Malta', 1),
(1, 'eurobet_uk', 'EuroBet UK', 'prod', 'USD', 'en', 'GB', 'Europe/London', 1),
-- CYPRUSPLAY (Kıbrıs) - 1 client
(2, 'cyprus_main', 'CyprusPlay Main', 'prod', 'EUR', 'en', 'CY', 'Asia/Nicosia', 1),
-- TURKBET (Türkiye) - 1 client
(3, 'turkbet_tr', 'TurkBet Türkiye', 'prod', 'TRY', 'tr', 'TR', 'Europe/Istanbul', 1);

-- ================================================================
-- 5. USERS (12 — sadeleştirilmiş)
-- ================================================================
-- Şifre: deneme (tüm kullanıcılar için aynı)
-- Hash: $argon2id$v=19$m=47104,t=1,p=1$/+pv+y99FW+8eHgBq9/RCg$ghMOBDkXj8OLGz8J9RF4m1xnrTm0o78HnG+Bkd2UJ+s

INSERT INTO security.users (company_id, first_name, last_name, email, username, password, status, language, timezone, currency, country) VALUES
-- Superadmin (SORTIS)
-- UYARI: Production'da şifre MUTLAKA değiştirilmeli!
(0, 'Super', 'Admin', 'superadmin@sortisgaming.com', 'superadmin',
 '$argon2id$v=19$m=47104,t=1,p=1$/+pv+y99FW+8eHgBq9/RCg$ghMOBDkXj8OLGz8J9RF4m1xnrTm0o78HnG+Bkd2UJ+s',
 1, 'tr', 'Europe/Istanbul', 'TRY', 'TR'),

-- Platform Admin (SORTIS)
(0, 'System', 'Admin', 'admin@sortisgaming.com', 'admin',
 '$argon2id$v=19$m=47104,t=1,p=1$/+pv+y99FW+8eHgBq9/RCg$ghMOBDkXj8OLGz8J9RF4m1xnrTm0o78HnG+Bkd2UJ+s',
 1, 'en', 'Europe/Istanbul', 'EUR', 'MT'),

-- CompanyAdmin - EUROBET (Malta)
(1, 'James', 'Wilson', 'eurobet@sortisgaming.com', 'eurobet',
 '$argon2id$v=19$m=47104,t=1,p=1$/+pv+y99FW+8eHgBq9/RCg$ghMOBDkXj8OLGz8J9RF4m1xnrTm0o78HnG+Bkd2UJ+s',
 1, 'en', 'Europe/Malta', 'EUR', 'MT'),

-- CompanyAdmin - CYPRUSPLAY (Kıbrıs)
(2, 'Andreas', 'Georgiou', 'cyprus@sortisgaming.com', 'cyprus',
 '$argon2id$v=19$m=47104,t=1,p=1$/+pv+y99FW+8eHgBq9/RCg$ghMOBDkXj8OLGz8J9RF4m1xnrTm0o78HnG+Bkd2UJ+s',
 1, 'en', 'Asia/Nicosia', 'EUR', 'CY'),

-- CompanyAdmin - TURKBET (Türkiye)
(3, 'Ahmet', 'Yılmaz', 'turkbet@sortisgaming.com', 'turkbet',
 '$argon2id$v=19$m=47104,t=1,p=1$/+pv+y99FW+8eHgBq9/RCg$ghMOBDkXj8OLGz8J9RF4m1xnrTm0o78HnG+Bkd2UJ+s',
 1, 'tr', 'Europe/Istanbul', 'TRY', 'TR'),

-- ClientAdmin - eurobet_eu
(1, 'Maria', 'Santos', 'eurobet.eu@sortisgaming.com', 'eurobet_eu',
 '$argon2id$v=19$m=47104,t=1,p=1$/+pv+y99FW+8eHgBq9/RCg$ghMOBDkXj8OLGz8J9RF4m1xnrTm0o78HnG+Bkd2UJ+s',
 1, 'en', 'Europe/Malta', 'EUR', 'MT'),

-- ClientAdmin - cyprus_main
(2, 'Nikos', 'Papadopoulos', 'cyprus.admin@sortisgaming.com', 'cyprus_admin',
 '$argon2id$v=19$m=47104,t=1,p=1$/+pv+y99FW+8eHgBq9/RCg$ghMOBDkXj8OLGz8J9RF4m1xnrTm0o78HnG+Bkd2UJ+s',
 1, 'en', 'Asia/Nicosia', 'EUR', 'CY'),

-- ClientAdmin - turkbet_tr
(3, 'Mehmet', 'Demir', 'turkbet.admin@sortisgaming.com', 'turkbet_admin',
 '$argon2id$v=19$m=47104,t=1,p=1$/+pv+y99FW+8eHgBq9/RCg$ghMOBDkXj8OLGz8J9RF4m1xnrTm0o78HnG+Bkd2UJ+s',
 1, 'tr', 'Europe/Istanbul', 'TRY', 'TR'),

-- Moderator - turkbet_tr (multi-client test: 3 client, 3 farklı rol)
(3, 'Ayşe', 'Kaya', 'turkbet.mod@sortisgaming.com', 'turkbet_mod',
 '$argon2id$v=19$m=47104,t=1,p=1$/+pv+y99FW+8eHgBq9/RCg$ghMOBDkXj8OLGz8J9RF4m1xnrTm0o78HnG+Bkd2UJ+s',
 1, 'tr', 'Europe/Istanbul', 'TRY', 'TR'),

-- Editor - turkbet_tr
(3, 'Zeynep', 'Çelik', 'turkbet.edit@sortisgaming.com', 'turkbet_edit',
 '$argon2id$v=19$m=47104,t=1,p=1$/+pv+y99FW+8eHgBq9/RCg$ghMOBDkXj8OLGz8J9RF4m1xnrTm0o78HnG+Bkd2UJ+s',
 1, 'tr', 'Europe/Istanbul', 'TRY', 'TR'),

-- Operator - turkbet_tr
(3, 'Ali', 'Öztürk', 'turkbet.op@sortisgaming.com', 'turkbet_op',
 '$argon2id$v=19$m=47104,t=1,p=1$/+pv+y99FW+8eHgBq9/RCg$ghMOBDkXj8OLGz8J9RF4m1xnrTm0o78HnG+Bkd2UJ+s',
 1, 'tr', 'Europe/Istanbul', 'TRY', 'TR'),

-- User - eurobet_eu
(1, 'John', 'Smith', 'eurobet.user@sortisgaming.com', 'eurobet_user',
 '$argon2id$v=19$m=47104,t=1,p=1$/+pv+y99FW+8eHgBq9/RCg$ghMOBDkXj8OLGz8J9RF4m1xnrTm0o78HnG+Bkd2UJ+s',
 1, 'en', 'Europe/Malta', 'EUR', 'MT');

-- ================================================================
-- 6. COMPANY PASSWORD POLICY
-- ================================================================
-- NOT: Users tablosu dolduktan SONRA çalıştırılmalı (created_by FK)

-- Company ID 0 (Sortis One Platform) — 90 gün, son 5 şifre
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
-- 7. GLOBAL ROL ATAMALARI (security.user_roles - client_id = NULL)
-- ================================================================

-- superadmin@sortisgaming.com → superadmin (global)
INSERT INTO security.user_roles (user_id, role_id, client_id)
SELECT u.id, r.id, NULL FROM security.users u, security.roles r
WHERE u.email = 'superadmin@sortisgaming.com' AND r.code = 'superadmin';

-- admin@sortisgaming.com → admin (global)
INSERT INTO security.user_roles (user_id, role_id, client_id)
SELECT u.id, r.id, NULL FROM security.users u, security.roles r
WHERE u.email = 'admin@sortisgaming.com' AND r.code = 'admin';

-- eurobet@sortisgaming.com → companyadmin (global)
INSERT INTO security.user_roles (user_id, role_id, client_id)
SELECT u.id, r.id, NULL FROM security.users u, security.roles r
WHERE u.email = 'eurobet@sortisgaming.com' AND r.code = 'companyadmin';

-- cyprus@sortisgaming.com → companyadmin (global)
INSERT INTO security.user_roles (user_id, role_id, client_id)
SELECT u.id, r.id, NULL FROM security.users u, security.roles r
WHERE u.email = 'cyprus@sortisgaming.com' AND r.code = 'companyadmin';

-- turkbet@sortisgaming.com → companyadmin (global)
INSERT INTO security.user_roles (user_id, role_id, client_id)
SELECT u.id, r.id, NULL FROM security.users u, security.roles r
WHERE u.email = 'turkbet@sortisgaming.com' AND r.code = 'companyadmin';

-- ================================================================
-- 8. CLIENT ROL ATAMALARI (security.user_roles - client_id = değer)
-- ================================================================

-- eurobet.eu@sortisgaming.com → clientadmin @ eurobet_eu
INSERT INTO security.user_roles (user_id, role_id, client_id)
SELECT u.id, r.id, t.id
FROM security.users u, security.roles r, core.clients t
WHERE u.email = 'eurobet.eu@sortisgaming.com' AND r.code = 'clientadmin' AND t.client_code = 'eurobet_eu';

-- cyprus.admin@sortisgaming.com → clientadmin @ cyprus_main
INSERT INTO security.user_roles (user_id, role_id, client_id)
SELECT u.id, r.id, t.id
FROM security.users u, security.roles r, core.clients t
WHERE u.email = 'cyprus.admin@sortisgaming.com' AND r.code = 'clientadmin' AND t.client_code = 'cyprus_main';

-- turkbet.admin@sortisgaming.com → clientadmin @ turkbet_tr
INSERT INTO security.user_roles (user_id, role_id, client_id)
SELECT u.id, r.id, t.id
FROM security.users u, security.roles r, core.clients t
WHERE u.email = 'turkbet.admin@sortisgaming.com' AND r.code = 'clientadmin' AND t.client_code = 'turkbet_tr';

-- turkbet.mod@sortisgaming.com → moderator @ turkbet_tr
INSERT INTO security.user_roles (user_id, role_id, client_id)
SELECT u.id, r.id, t.id
FROM security.users u, security.roles r, core.clients t
WHERE u.email = 'turkbet.mod@sortisgaming.com' AND r.code = 'moderator' AND t.client_code = 'turkbet_tr';

-- turkbet.mod@sortisgaming.com → operator @ eurobet_eu (multi-client)
INSERT INTO security.user_roles (user_id, role_id, client_id)
SELECT u.id, r.id, t.id
FROM security.users u, security.roles r, core.clients t
WHERE u.email = 'turkbet.mod@sortisgaming.com' AND r.code = 'operator' AND t.client_code = 'eurobet_eu';

-- turkbet.mod@sortisgaming.com → clientadmin @ cyprus_main (multi-client)
INSERT INTO security.user_roles (user_id, role_id, client_id)
SELECT u.id, r.id, t.id
FROM security.users u, security.roles r, core.clients t
WHERE u.email = 'turkbet.mod@sortisgaming.com' AND r.code = 'clientadmin' AND t.client_code = 'cyprus_main';

-- turkbet.edit@sortisgaming.com → editor @ turkbet_tr
INSERT INTO security.user_roles (user_id, role_id, client_id)
SELECT u.id, r.id, t.id
FROM security.users u, security.roles r, core.clients t
WHERE u.email = 'turkbet.edit@sortisgaming.com' AND r.code = 'editor' AND t.client_code = 'turkbet_tr';

-- turkbet.op@sortisgaming.com → operator @ turkbet_tr
INSERT INTO security.user_roles (user_id, role_id, client_id)
SELECT u.id, r.id, t.id
FROM security.users u, security.roles r, core.clients t
WHERE u.email = 'turkbet.op@sortisgaming.com' AND r.code = 'operator' AND t.client_code = 'turkbet_tr';

-- eurobet.user@sortisgaming.com → user @ eurobet_eu
INSERT INTO security.user_roles (user_id, role_id, client_id)
SELECT u.id, r.id, t.id
FROM security.users u, security.roles r, core.clients t
WHERE u.email = 'eurobet.user@sortisgaming.com' AND r.code = 'user' AND t.client_code = 'eurobet_eu';

-- ================================================================
-- 9. CLIENT ERİŞİM İZİNLERİ (security.user_allowed_clients)
-- ================================================================
-- Sadece client-level kullanıcılar için.
-- Platform (superadmin, admin) bypass eder, company admin company üzerinden erişir.

-- eurobet.eu@sortisgaming.com → eurobet_eu
INSERT INTO security.user_allowed_clients (user_id, client_id)
SELECT u.id, t.id FROM security.users u, core.clients t
WHERE u.email = 'eurobet.eu@sortisgaming.com' AND t.client_code = 'eurobet_eu';

-- cyprus.admin@sortisgaming.com → cyprus_main
INSERT INTO security.user_allowed_clients (user_id, client_id)
SELECT u.id, t.id FROM security.users u, core.clients t
WHERE u.email = 'cyprus.admin@sortisgaming.com' AND t.client_code = 'cyprus_main';

-- turkbet.admin@sortisgaming.com → turkbet_tr
INSERT INTO security.user_allowed_clients (user_id, client_id)
SELECT u.id, t.id FROM security.users u, core.clients t
WHERE u.email = 'turkbet.admin@sortisgaming.com' AND t.client_code = 'turkbet_tr';

-- turkbet.mod@sortisgaming.com → turkbet_tr + eurobet_eu + cyprus_main (multi-client)
INSERT INTO security.user_allowed_clients (user_id, client_id)
SELECT u.id, t.id FROM security.users u, core.clients t
WHERE u.email = 'turkbet.mod@sortisgaming.com' AND t.client_code = 'turkbet_tr';

INSERT INTO security.user_allowed_clients (user_id, client_id)
SELECT u.id, t.id FROM security.users u, core.clients t
WHERE u.email = 'turkbet.mod@sortisgaming.com' AND t.client_code = 'eurobet_eu';

INSERT INTO security.user_allowed_clients (user_id, client_id)
SELECT u.id, t.id FROM security.users u, core.clients t
WHERE u.email = 'turkbet.mod@sortisgaming.com' AND t.client_code = 'cyprus_main';

-- turkbet.edit@sortisgaming.com → turkbet_tr
INSERT INTO security.user_allowed_clients (user_id, client_id)
SELECT u.id, t.id FROM security.users u, core.clients t
WHERE u.email = 'turkbet.edit@sortisgaming.com' AND t.client_code = 'turkbet_tr';

-- turkbet.op@sortisgaming.com → turkbet_tr
INSERT INTO security.user_allowed_clients (user_id, client_id)
SELECT u.id, t.id FROM security.users u, core.clients t
WHERE u.email = 'turkbet.op@sortisgaming.com' AND t.client_code = 'turkbet_tr';

-- eurobet.user@sortisgaming.com → eurobet_eu
INSERT INTO security.user_allowed_clients (user_id, client_id)
SELECT u.id, t.id FROM security.users u, core.clients t
WHERE u.email = 'eurobet.user@sortisgaming.com' AND t.client_code = 'eurobet_eu';

-- ================================================================
-- 10. CLIENT PARA BİRİMLERİ (11)
-- ================================================================

INSERT INTO core.client_currencies (client_id, currency_code, is_enabled)
SELECT t.id, c.code, true FROM core.clients t
CROSS JOIN (VALUES ('EUR'), ('USD'), ('GBP')) AS c(code)
WHERE t.client_code = 'eurobet_eu';

INSERT INTO core.client_currencies (client_id, currency_code, is_enabled)
SELECT t.id, c.code, true FROM core.clients t
CROSS JOIN (VALUES ('GBP'), ('EUR'), ('USD')) AS c(code)
WHERE t.client_code = 'eurobet_uk';

INSERT INTO core.client_currencies (client_id, currency_code, is_enabled)
SELECT t.id, c.code, true FROM core.clients t
CROSS JOIN (VALUES ('EUR'), ('USD')) AS c(code)
WHERE t.client_code = 'cyprus_main';

INSERT INTO core.client_currencies (client_id, currency_code, is_enabled)
SELECT t.id, c.code, true FROM core.clients t
CROSS JOIN (VALUES ('TRY'), ('EUR'), ('USD')) AS c(code)
WHERE t.client_code = 'turkbet_tr';

-- ================================================================
-- 11. CLIENT KRİPTO PARA BİRİMLERİ (9)
-- ================================================================

INSERT INTO core.client_cryptocurrencies (client_id, symbol, is_enabled)
SELECT t.id, c.symbol, true FROM core.clients t
CROSS JOIN (VALUES ('BTC'), ('ETH'), ('SOL')) AS c(symbol)
WHERE t.client_code = 'eurobet_eu';

INSERT INTO core.client_cryptocurrencies (client_id, symbol, is_enabled)
SELECT t.id, c.symbol, true FROM core.clients t
CROSS JOIN (VALUES ('BTC'), ('ETH')) AS c(symbol)
WHERE t.client_code = 'eurobet_uk';

INSERT INTO core.client_cryptocurrencies (client_id, symbol, is_enabled)
SELECT t.id, c.symbol, true FROM core.clients t
CROSS JOIN (VALUES ('BTC'), ('ETH')) AS c(symbol)
WHERE t.client_code = 'cyprus_main';

INSERT INTO core.client_cryptocurrencies (client_id, symbol, is_enabled)
SELECT t.id, c.symbol, true FROM core.clients t
CROSS JOIN (VALUES ('BTC'), ('SOL')) AS c(symbol)
WHERE t.client_code = 'turkbet_tr';

-- ================================================================
-- 12. CLIENT DİLLERİ (8 — 4 client × 2 dil)
-- ================================================================

INSERT INTO core.client_languages (client_id, language_code, is_enabled)
SELECT t.id, l.code, true FROM core.clients t
CROSS JOIN (VALUES ('en'), ('tr')) AS l(code);

-- ================================================================
-- 13. JURISDICTIONS & KYC COMPLIANCE DATA
-- ================================================================
-- Jurisdiction ve KYC verileri client_jurisdictions'dan ONCE yuklenmeli.
-- client_jurisdictions INSERT'leri catalog.jurisdictions tablosuna bagli.

-- ================================================================
-- 13.1 JURISDICTIONS (12 — Lisans Otoriteleri)
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
-- 13.2 KYC POLICIES (12 — Her Jurisdiction için)
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
-- 13.3 KYC DOCUMENT REQUIREMENTS (10)
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
-- 13.4 KYC LEVEL REQUIREMENTS (9)
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
-- 13.5 RESPONSIBLE GAMING POLICIES (4)
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
-- 14. CLIENT JURISDICTIONS (5)
-- ================================================================

-- eurobet_eu → MGA (primary) + UKGC
INSERT INTO core.client_jurisdictions (client_id, jurisdiction_id, license_number, license_issued_at, license_expires_at, is_primary, status)
SELECT t.id, j.id, 'MGA/B2C/123/2024', '2024-01-01', '2029-01-01', TRUE, 'active'
FROM core.clients t, catalog.jurisdictions j
WHERE t.client_code = 'eurobet_eu' AND j.code = 'MGA';

INSERT INTO core.client_jurisdictions (client_id, jurisdiction_id, license_number, license_issued_at, license_expires_at, is_primary, status)
SELECT t.id, j.id, 'GC-000123-R-123456', '2024-01-01', '2029-01-01', FALSE, 'active'
FROM core.clients t, catalog.jurisdictions j
WHERE t.client_code = 'eurobet_eu' AND j.code = 'UKGC';

-- cyprus_main → CUR
INSERT INTO core.client_jurisdictions (client_id, jurisdiction_id, license_number, license_issued_at, license_expires_at, is_primary, status)
SELECT t.id, j.id, 'CEG/1234/2024', '2024-01-01', '2025-01-01', TRUE, 'active'
FROM core.clients t, catalog.jurisdictions j
WHERE t.client_code = 'cyprus_main' AND j.code = 'CUR';

-- eurobet_uk → UKGC (primary, strict)
INSERT INTO core.client_jurisdictions (client_id, jurisdiction_id, license_number, license_issued_at, license_expires_at, is_primary, status)
SELECT t.id, j.id, 'GC-000456-R-789012', '2024-01-01', '2029-01-01', TRUE, 'active'
FROM core.clients t, catalog.jurisdictions j
WHERE t.client_code = 'eurobet_uk' AND j.code = 'UKGC';

-- turkbet_tr → CUR
INSERT INTO core.client_jurisdictions (client_id, jurisdiction_id, license_number, license_issued_at, license_expires_at, is_primary, status)
SELECT t.id, j.id, 'CEG/5678/2024', '2024-01-01', '2025-01-01', TRUE, 'active'
FROM core.clients t, catalog.jurisdictions j
WHERE t.client_code = 'turkbet_tr' AND j.code = 'CUR';

-- ================================================================
-- 15. CLIENT AYARLARI
-- ================================================================

-- SMS API Ayarları
INSERT INTO core.client_settings (client_id, category, setting_key, setting_value, description)
SELECT t.id, 'Integration', 'sms_provider',
    '{"provider": "twilio", "account_sid": "AC_STAGING_SID", "auth_token": "STAGING_AUTH_TOKEN", "from_number": "+15005550006", "enabled": true, "sandbox_mode": true}'::jsonb,
    'SMS provider configuration (Twilio)'
FROM core.clients t;

-- Email Ayarları
INSERT INTO core.client_settings (client_id, category, setting_key, setting_value, description)
SELECT t.id, 'Integration', 'email_provider',
    '{"provider": "smtp", "host": "smtp.mailtrap.io", "port": 587, "username": "staging_user", "password": "staging_pass", "from_address": "noreply@staging.sortisgaming.com", "from_name": "Sortis One Platform", "use_ssl": true, "enabled": true}'::jsonb,
    'Email/SMTP provider configuration'
FROM core.clients t;

-- Client Birleşik DB Bağlantısı (client_{id}) - Tüm schema'lar tek DB'de
INSERT INTO core.client_settings (client_id, category, setting_key, setting_value, description)
SELECT t.id, 'Database', 'connection_client',
    format('{"host": "207.180.241.230", "port": 5433, "database": "client_%s", "username": "postgres", "password": "NucleoPostgres2026", "ssl_mode": "prefer", "min_pool_size": 5, "max_pool_size": 50, "connection_timeout": 30, "command_timeout": 60, "replica_enabled": true, "replica_port": 5434, "replica_min_pool_size": 2, "replica_max_pool_size": 15}', t.id)::jsonb,
    'Unified client database connection (30 schemas: core business, log, audit, report, affiliate)'
FROM core.clients t;

-- Password Policy Ayarları
INSERT INTO core.client_settings (client_id, category, setting_key, setting_value, description)
SELECT t.id, 'Security', 'password_expiry_days',
    '30'::jsonb,
    'Player password expiry period in days (0 = never expires)'
FROM core.clients t;

INSERT INTO core.client_settings (client_id, category, setting_key, setting_value, description)
SELECT t.id, 'Security', 'password_history_count',
    '3'::jsonb,
    'Number of previous passwords to check for reuse prevention'
FROM core.clients t;

INSERT INTO core.client_settings (client_id, category, setting_key, setting_value, description)
SELECT t.id, 'Security', 'password_min_length',
    '8'::jsonb,
    'Minimum password length requirement'
FROM core.clients t;

-- Encryption: PII Key (Player PII sifreleme — AES-256, her client'a unique sabit test key)
INSERT INTO core.client_settings (client_id, category, setting_key, setting_value, description)
SELECT t.id, 'Security', 'encryption_pii_key',
    CASE t.client_code
        WHEN 'eurobet_eu'  THEN '"QnGgAo7/r9A8HcZlyFEuR6B07rmbvR+o0p/kz5VQHO8="'::jsonb
        WHEN 'eurobet_uk'  THEN '"+styQB8cdu/BgKHq8LVQSK62pwlVKajAwjh5oNZI8n4="'::jsonb
        WHEN 'cyprus_main' THEN '"xJggE72dj8dL/Amoc2TySlc+80wLzOo1VmRsQQhAGbs="'::jsonb
        WHEN 'turkbet_tr'  THEN '"Bo5+mdYOdDdbXA5ZXvzrWhz4dhcr2kTXTI0q6OuXn60="'::jsonb
    END,
    'Player PII encryption key (AES-256-GCM, Base64)'
FROM core.clients t;

-- Encryption: Master Key (SignalR group key wrap KEK — AES-256, her client'a unique sabit test key)
INSERT INTO core.client_settings (client_id, category, setting_key, setting_value, description)
SELECT t.id, 'Security', 'encryption_master_key',
    CASE t.client_code
        WHEN 'eurobet_eu'  THEN '"9l1eVTgIbM5QGmi+0gAApow+Oe1KiCWer9eqmiCa6u8="'::jsonb
        WHEN 'eurobet_uk'  THEN '"EyoH/exSZdfXZbuzB5J9JGTY0k3h9HQZXSxL4N0Sfj8="'::jsonb
        WHEN 'cyprus_main' THEN '"TaRXIdDSZFNZkfcTnrb9psFLRdF/TzBGRg5Pzk9VdxQ="'::jsonb
        WHEN 'turkbet_tr'  THEN '"KdfI3HTA3q8pNc9WVnGdJhjQoijgJroNm9gu82p4zu0="'::jsonb
    END,
    'Client master encryption key for key wrapping (KEK, AES-256-GCM, Base64)'
FROM core.clients t;

-- Silo Placement Ayarlari (Client Cluster grain placement)
-- Client 2 (eurobet_uk) ve Client 3 (cyprus_main) dedicated-s2 pool'unda, digerleri general
INSERT INTO core.client_settings (client_id, category, setting_key, setting_value, description)
SELECT t.id, 'Infrastructure', 'silo_placement',
    CASE WHEN t.client_code IN ('eurobet_uk', 'cyprus_main') THEN '"dedicated-s2"'::jsonb
         ELSE '"general"'::jsonb
    END,
    'Silo placement pool assignment (general, dedicated-s2, etc.)'
FROM core.clients t;

-- ================================================================
-- CLIENT REDIS BAĞLANTILARI (HER CLIENT İÇİN ZORUNLU)
-- ================================================================

-- eurobet_eu + turkbet_tr → Shared Redis (207.180.241.230:7003)
INSERT INTO core.client_settings (client_id, category, setting_key, setting_value, description)
SELECT t.id, 'Infrastructure', 'connection_redis',
    jsonb_build_object(
        'host', '207.180.241.230', 'port', 7003,
        'password', 'NucleoRedis2026!',
        'default_database', 0, 'cluster_mode', false, 'use_ssl', false,
        'connect_timeout', 10000, 'sync_timeout', 5000, 'async_timeout', 5000,
        'keep_alive', 60, 'client_name', t.client_code || '-redis'
    ),
    'Client Redis connection configuration'
FROM core.clients t WHERE t.client_code IN ('eurobet_eu', 'turkbet_tr');

-- eurobet_uk → Dedicated Redis (207.180.241.193:7003)
INSERT INTO core.client_settings (client_id, category, setting_key, setting_value, description)
SELECT t.id, 'Infrastructure', 'connection_redis',
    jsonb_build_object(
        'host', '207.180.241.193', 'port', 7003,
        'password', 'NucleoRedis2026!',
        'default_database', 0, 'cluster_mode', false, 'use_ssl', false,
        'connect_timeout', 10000, 'sync_timeout', 5000, 'async_timeout', 5000,
        'keep_alive', 60, 'client_name', 'eurobet_uk-redis'
    ),
    'Client Redis connection configuration'
FROM core.clients t WHERE t.client_code = 'eurobet_uk';

-- cyprus_main → Dedicated Redis (207.180.241.142:7003)
INSERT INTO core.client_settings (client_id, category, setting_key, setting_value, description)
SELECT t.id, 'Infrastructure', 'connection_redis',
    jsonb_build_object(
        'host', '207.180.241.142', 'port', 7003,
        'password', 'NucleoRedis2026!',
        'default_database', 0, 'cluster_mode', false, 'use_ssl', false,
        'connect_timeout', 10000, 'sync_timeout', 5000, 'async_timeout', 5000,
        'keep_alive', 60, 'client_name', 'cyprus_main-redis'
    ),
    'Client Redis connection configuration'
FROM core.clients t WHERE t.client_code = 'cyprus_main';

-- ================================================================
-- 16. SEQUENCE RESET'LER
-- ================================================================

SELECT setval('core.companies_id_seq', COALESCE((SELECT MAX(id) FROM core.companies), 0) + 1, false);
SELECT setval('core.clients_id_seq', COALESCE((SELECT MAX(id) FROM core.clients), 0) + 1, false);
SELECT setval('catalog.jurisdictions_id_seq', COALESCE((SELECT MAX(id) FROM catalog.jurisdictions), 0) + 1, false);

-- ================================================================
-- 17. DOĞRULAMA
-- ================================================================

-- Blok 1: Ana Veriler
DO $$
DECLARE
    v_companies INT; v_roles INT; v_clients INT; v_users INT;
    v_global_roles INT; v_client_roles INT; v_client_access INT;
    v_password_policies INT; v_currencies INT; v_cryptocurrencies INT;
    v_languages INT; v_settings INT;
BEGIN
    SELECT COUNT(*) INTO v_companies FROM core.companies;
    SELECT COUNT(*) INTO v_roles FROM security.roles;
    SELECT COUNT(*) INTO v_clients FROM core.clients;
    SELECT COUNT(*) INTO v_users FROM security.users;
    SELECT COUNT(*) INTO v_global_roles FROM security.user_roles WHERE client_id IS NULL;
    SELECT COUNT(*) INTO v_client_roles FROM security.user_roles WHERE client_id IS NOT NULL;
    SELECT COUNT(*) INTO v_client_access FROM security.user_allowed_clients;
    SELECT COUNT(*) INTO v_password_policies FROM security.company_password_policy;
    SELECT COUNT(*) INTO v_currencies FROM core.client_currencies;
    SELECT COUNT(*) INTO v_cryptocurrencies FROM core.client_cryptocurrencies;
    SELECT COUNT(*) INTO v_languages FROM core.client_languages;
    SELECT COUNT(*) INTO v_settings FROM core.client_settings;

    RAISE NOTICE '================================================';
    RAISE NOTICE 'SEED TEST DATA — ANA VERİLER';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Companies: % (beklenen: 4)', v_companies;
    RAISE NOTICE 'Roles: % (beklenen: 8)', v_roles;
    RAISE NOTICE 'Clients: % (beklenen: 4)', v_clients;
    RAISE NOTICE 'Users: % (beklenen: 12)', v_users;
    RAISE NOTICE 'Global Role Assignments: % (beklenen: 5)', v_global_roles;
    RAISE NOTICE 'Client Role Assignments: % (beklenen: 9)', v_client_roles;
    RAISE NOTICE 'Client Access: % (beklenen: 9)', v_client_access;
    RAISE NOTICE 'Company Password Policies: % (beklenen: 3)', v_password_policies;
    RAISE NOTICE 'Client Currencies: % (beklenen: 11)', v_currencies;
    RAISE NOTICE 'Client Cryptocurrencies: % (beklenen: 9)', v_cryptocurrencies;
    RAISE NOTICE 'Client Languages: % (beklenen: 8)', v_languages;
    RAISE NOTICE 'Client Settings: % (beklenen: 40)', v_settings;
    RAISE NOTICE '================================================';
END $$;

-- Blok 2: Compliance
DO $$
DECLARE
    v_jurisdictions INT; v_kyc_policies INT; v_doc_reqs INT;
    v_level_reqs INT; v_rg_policies INT; v_client_j INT;
BEGIN
    SELECT COUNT(*) INTO v_jurisdictions FROM catalog.jurisdictions;
    SELECT COUNT(*) INTO v_kyc_policies FROM catalog.kyc_policies;
    SELECT COUNT(*) INTO v_doc_reqs FROM catalog.kyc_document_requirements;
    SELECT COUNT(*) INTO v_level_reqs FROM catalog.kyc_level_requirements;
    SELECT COUNT(*) INTO v_rg_policies FROM catalog.responsible_gaming_policies;
    SELECT COUNT(*) INTO v_client_j FROM core.client_jurisdictions;

    RAISE NOTICE '================================================';
    RAISE NOTICE 'SEED TEST DATA — COMPLIANCE';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Jurisdictions: % (beklenen: 12)', v_jurisdictions;
    RAISE NOTICE 'KYC Policies: % (beklenen: 12)', v_kyc_policies;
    RAISE NOTICE 'Document Requirements: % (beklenen: 10)', v_doc_reqs;
    RAISE NOTICE 'Level Requirements: % (beklenen: 9)', v_level_reqs;
    RAISE NOTICE 'Responsible Gaming Policies: % (beklenen: 4)', v_rg_policies;
    RAISE NOTICE 'Client Jurisdictions: % (beklenen: 5)', v_client_j;
    RAISE NOTICE '================================================';
END $$;

-- ================================================================
-- TEST KULLANICILARI ÖZETİ
-- ================================================================
--
-- | #  | Email                   | Company     | Global Rol   | Client Rolleri                                              |
-- |----|-------------------------|-------------|--------------|-------------------------------------------------------------|
-- | 1  | superadmin@sortisgaming.com    | SORTIS      | superadmin   | —                                                           |
-- | 2  | admin@sortisgaming.com         | SORTIS      | admin        | —                                                           |
-- | 3  | eurobet@sortisgaming.com       | EUROBET     | companyadmin | —                                                           |
-- | 4  | cyprus@sortisgaming.com        | CYPRUSPLAY  | companyadmin | —                                                           |
-- | 5  | turkbet@sortisgaming.com       | TURKBET     | companyadmin | —                                                           |
-- | 6  | eurobet.eu@sortisgaming.com    | EUROBET     | —            | clientadmin@eurobet_eu                                      |
-- | 7  | cyprus.admin@sortisgaming.com  | CYPRUSPLAY  | —            | clientadmin@cyprus_main                                     |
-- | 8  | turkbet.admin@sortisgaming.com | TURKBET     | —            | clientadmin@turkbet_tr                                      |
-- | 9  | turkbet.mod@sortisgaming.com   | TURKBET     | —            | moderator@turkbet_tr, operator@eurobet_eu, clientadmin@cyprus_main |
-- | 10 | turkbet.edit@sortisgaming.com  | TURKBET     | —            | editor@turkbet_tr                                           |
-- | 11 | turkbet.op@sortisgaming.com    | TURKBET     | —            | operator@turkbet_tr                                         |
-- | 12 | eurobet.user@sortisgaming.com  | EUROBET     | —            | user@eurobet_eu                                             |
--
-- Tüm şifreler: deneme
-- ================================================================
