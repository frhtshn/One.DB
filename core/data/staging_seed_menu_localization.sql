-- ============================================================================
-- STAGING - MENU LOCALIZATION SEED
-- Nucleo.Platform
-- ============================================================================
-- Bu dosya menü UI çevirilerini içerir (staging/dev ortamları için).
-- Nucleo.DB'deki localization pattern'ini takip eder.
-- ============================================================================
-- Çalıştırma: psql -U postgres -d nucleo -f core/data/staging_seed_menu_localization.sql
-- NOT: staging_seed.sql'den ÖNCE çalıştırılmalı (menüler localization'a bağlı)
-- ============================================================================
-- Key Pattern: ui.{element-type}.{code}
-- Element Types: menu-group, menu, submenu, page, tab, context
-- ============================================================================
-- Production için: localization_keys.sql ve localization_values_*.sql
-- dosyalarına eklenecek.
-- ============================================================================

-- ============================================================================
-- 1. LOCALIZATION KEYS
-- ============================================================================
-- Sadece menu ile ilgili key'leri ekle, mevcut olanları atla

INSERT INTO catalog.localization_keys (localization_key, domain, category, description) VALUES

-- ============================================================================
-- MENU GROUPS
-- ============================================================================
('ui.menu-group.platform', 'ui', 'menu', 'Platform menü grubu'),
('ui.menu-group.companies', 'ui', 'menu', 'Companies menü grubu'),
('ui.menu-group.tenants', 'ui', 'menu', 'Tenants menü grubu'),
('ui.menu-group.audit', 'ui', 'menu', 'Audit menü grubu'),

-- ============================================================================
-- MENUS
-- ============================================================================
-- Platform
('ui.menu.system', 'ui', 'menu', 'System menüsü'),
('ui.menu.rbac', 'ui', 'menu', 'RBAC menüsü'),

-- Companies
('ui.menu.companies', 'ui', 'menu', 'Şirketler menüsü'),
('ui.menu.company-users', 'ui', 'menu', 'Company kullanıcıları menüsü'),

-- Tenants
('ui.menu.tenants', 'ui', 'menu', 'Tenantlar menüsü'),
('ui.menu.tenant-users', 'ui', 'menu', 'Tenant kullanıcıları menüsü'),
('ui.menu.tenant-settings', 'ui', 'menu', 'Tenant ayarları menüsü'),

-- Audit
('ui.menu.audit-logs', 'ui', 'menu', 'Audit logs menüsü'),

-- ============================================================================
-- SUBMENUS
-- ============================================================================
-- System
('ui.submenu.health', 'ui', 'menu', 'Health check alt menüsü'),
('ui.submenu.logs', 'ui', 'menu', 'Logs alt menüsü'),
('ui.submenu.system-settings', 'ui', 'menu', 'System settings alt menüsü'),

-- RBAC
('ui.submenu.menus', 'ui', 'menu', 'Menü yönetimi alt menüsü'),
('ui.submenu.roles', 'ui', 'menu', 'Roller alt menüsü'),
('ui.submenu.permissions', 'ui', 'menu', 'Permissionlar alt menüsü'),

-- ============================================================================
-- PAGES
-- ============================================================================
-- Platform - System
('ui.page.health', 'ui', 'page', 'Health check sayfası'),
('ui.page.logs', 'ui', 'page', 'Logs sayfası'),
('ui.page.system-settings', 'ui', 'page', 'System settings sayfası'),

-- Platform - RBAC
('ui.page.menu-management', 'ui', 'page', 'Menü yönetimi sayfası'),
('ui.page.roles', 'ui', 'page', 'Roller sayfası'),
('ui.page.permissions', 'ui', 'page', 'Permissionlar sayfası'),

-- Companies
('ui.page.companies', 'ui', 'page', 'Şirketler sayfası'),
('ui.page.company-detail', 'ui', 'page', 'Şirket detay sayfası'),
('ui.page.company-users', 'ui', 'page', 'Company kullanıcıları sayfası'),

-- Tenants
('ui.page.tenants', 'ui', 'page', 'Tenantlar sayfası'),
('ui.page.tenant-detail', 'ui', 'page', 'Tenant detay sayfası'),
('ui.page.tenant-users', 'ui', 'page', 'Tenant kullanıcıları sayfası'),
('ui.page.tenant-user-detail', 'ui', 'page', 'Tenant kullanıcı detay sayfası'),
('ui.page.tenant-settings', 'ui', 'page', 'Tenant ayarları sayfası'),

-- Audit
('ui.page.audit-logs', 'ui', 'page', 'Audit logs sayfası'),
('ui.page.audit-log-detail', 'ui', 'page', 'Audit log detay sayfası'),

-- ============================================================================
-- CONTEXTS
-- ============================================================================
-- Company
('ui.context.company-info', 'ui', 'context', 'Şirket bilgileri context'),
('ui.context.company-tenants', 'ui', 'context', 'Şirket tenantları context'),
('ui.context.company-users', 'ui', 'context', 'Şirket kullanıcıları context'),

-- Tenant
('ui.context.tenant-info', 'ui', 'context', 'Tenant bilgileri context'),
('ui.context.tenant-users', 'ui', 'context', 'Tenant kullanıcıları context'),
('ui.context.tenant-settings', 'ui', 'context', 'Tenant ayarları context')

ON CONFLICT (localization_key) DO NOTHING;

-- ============================================================================
-- 2. LOCALIZATION VALUES - ENGLISH (en)
-- ============================================================================

INSERT INTO catalog.localization_values (localization_key_id, language_code, localized_text, created_at)
SELECT k.id, 'en', v.text, NOW()
FROM catalog.localization_keys k
JOIN (VALUES
    -- Menu Groups
    ('ui.menu-group.platform', 'Platform'),
    ('ui.menu-group.companies', 'Company Management'),
    ('ui.menu-group.tenants', 'Tenant Management'),
    ('ui.menu-group.audit', 'Audit'),

    -- Menus - Platform
    ('ui.menu.system', 'System'),
    ('ui.menu.rbac', 'RBAC Management'),

    -- Menus - Companies
    ('ui.menu.companies', 'Company List'),
    ('ui.menu.company-users', 'Company Users'),

    -- Menus - Tenants
    ('ui.menu.tenants', 'Tenant List'),
    ('ui.menu.tenant-users', 'Users'),
    ('ui.menu.tenant-settings', 'Settings'),

    -- Menus - Audit
    ('ui.menu.audit-logs', 'Audit Logs'),

    -- Submenus - System
    ('ui.submenu.health', 'Health Check'),
    ('ui.submenu.logs', 'Logs'),
    ('ui.submenu.system-settings', 'System Settings'),

    -- Submenus - RBAC
    ('ui.submenu.menus', 'Menu Management'),
    ('ui.submenu.roles', 'Roles'),
    ('ui.submenu.permissions', 'Permissions'),

    -- Pages - Platform
    ('ui.page.health', 'Health Check'),
    ('ui.page.logs', 'System Logs'),
    ('ui.page.system-settings', 'System Settings'),
    ('ui.page.menu-management', 'Menu Management'),
    ('ui.page.roles', 'Roles'),
    ('ui.page.permissions', 'Permissions'),

    -- Pages - Companies
    ('ui.page.companies', 'Companies'),
    ('ui.page.company-detail', 'Company Details'),
    ('ui.page.company-users', 'Company Users'),

    -- Pages - Tenants
    ('ui.page.tenants', 'Tenants'),
    ('ui.page.tenant-detail', 'Tenant Details'),
    ('ui.page.tenant-users', 'Tenant Users'),
    ('ui.page.tenant-user-detail', 'User Details'),
    ('ui.page.tenant-settings', 'Tenant Settings'),

    -- Pages - Audit
    ('ui.page.audit-logs', 'Audit Logs'),
    ('ui.page.audit-log-detail', 'Audit Log Details'),

    -- Contexts - Company
    ('ui.context.company-info', 'Company Info'),
    ('ui.context.company-tenants', 'Tenants'),
    ('ui.context.company-users', 'Users'),

    -- Contexts - Tenant
    ('ui.context.tenant-info', 'Tenant Info'),
    ('ui.context.tenant-users', 'Users'),
    ('ui.context.tenant-settings', 'Settings')
) AS v(key, text) ON k.localization_key = v.key
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 3. LOCALIZATION VALUES - TURKISH (tr)
-- ============================================================================

INSERT INTO catalog.localization_values (localization_key_id, language_code, localized_text, created_at)
SELECT k.id, 'tr', v.text, NOW()
FROM catalog.localization_keys k
JOIN (VALUES
    -- Menu Groups
    ('ui.menu-group.platform', 'Platform'),
    ('ui.menu-group.companies', 'Şirket Yönetimi'),
    ('ui.menu-group.tenants', 'Tenant Yönetimi'),
    ('ui.menu-group.audit', 'Denetim'),

    -- Menus - Platform
    ('ui.menu.system', 'Sistem'),
    ('ui.menu.rbac', 'RBAC Yönetimi'),

    -- Menus - Companies
    ('ui.menu.companies', 'Şirket Listesi'),
    ('ui.menu.company-users', 'Şirket Kullanıcıları'),

    -- Menus - Tenants
    ('ui.menu.tenants', 'Tenant Listesi'),
    ('ui.menu.tenant-users', 'Kullanıcılar'),
    ('ui.menu.tenant-settings', 'Ayarlar'),

    -- Menus - Audit
    ('ui.menu.audit-logs', 'Denetim Kayıtları'),

    -- Submenus - System
    ('ui.submenu.health', 'Sağlık Kontrolü'),
    ('ui.submenu.logs', 'Loglar'),
    ('ui.submenu.system-settings', 'Sistem Ayarları'),

    -- Submenus - RBAC
    ('ui.submenu.menus', 'Menü Yönetimi'),
    ('ui.submenu.roles', 'Roller'),
    ('ui.submenu.permissions', 'Yetkiler'),

    -- Pages - Platform
    ('ui.page.health', 'Sağlık Kontrolü'),
    ('ui.page.logs', 'Sistem Logları'),
    ('ui.page.system-settings', 'Sistem Ayarları'),
    ('ui.page.menu-management', 'Menü Yönetimi'),
    ('ui.page.roles', 'Roller'),
    ('ui.page.permissions', 'Yetkiler'),

    -- Pages - Companies
    ('ui.page.companies', 'Şirketler'),
    ('ui.page.company-detail', 'Şirket Detayı'),
    ('ui.page.company-users', 'Şirket Kullanıcıları'),

    -- Pages - Tenants
    ('ui.page.tenants', 'Tenantlar'),
    ('ui.page.tenant-detail', 'Tenant Detayı'),
    ('ui.page.tenant-users', 'Kullanıcılar'),
    ('ui.page.tenant-user-detail', 'Kullanıcı Detayı'),
    ('ui.page.tenant-settings', 'Tenant Ayarları'),

    -- Pages - Audit
    ('ui.page.audit-logs', 'Denetim Kayıtları'),
    ('ui.page.audit-log-detail', 'Denetim Kaydı Detayı'),

    -- Contexts - Company
    ('ui.context.company-info', 'Şirket Bilgileri'),
    ('ui.context.company-tenants', 'Tenantlar'),
    ('ui.context.company-users', 'Kullanıcılar'),

    -- Contexts - Tenant
    ('ui.context.tenant-info', 'Tenant Bilgileri'),
    ('ui.context.tenant-users', 'Kullanıcılar'),
    ('ui.context.tenant-settings', 'Ayarlar')
) AS v(key, text) ON k.localization_key = v.key
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 4. DOĞRULAMA
-- ============================================================================

DO $$
DECLARE
    v_key_count INT;
    v_en_count INT;
    v_tr_count INT;
BEGIN
    SELECT COUNT(*) INTO v_key_count
    FROM catalog.localization_keys
    WHERE localization_key LIKE 'ui.menu%'
       OR localization_key LIKE 'ui.submenu%'
       OR localization_key LIKE 'ui.page%'
       OR localization_key LIKE 'ui.context%';

    SELECT COUNT(*) INTO v_en_count
    FROM catalog.localization_values lv
    JOIN catalog.localization_keys lk ON lv.localization_key_id = lk.id
    WHERE lv.language_code = 'en'
      AND (lk.localization_key LIKE 'ui.menu%'
           OR lk.localization_key LIKE 'ui.submenu%'
           OR lk.localization_key LIKE 'ui.page%'
           OR lk.localization_key LIKE 'ui.context%');

    SELECT COUNT(*) INTO v_tr_count
    FROM catalog.localization_values lv
    JOIN catalog.localization_keys lk ON lv.localization_key_id = lk.id
    WHERE lv.language_code = 'tr'
      AND (lk.localization_key LIKE 'ui.menu%'
           OR lk.localization_key LIKE 'ui.submenu%'
           OR lk.localization_key LIKE 'ui.page%'
           OR lk.localization_key LIKE 'ui.context%');

    RAISE NOTICE '================================================';
    RAISE NOTICE 'MENU LOCALIZATION SEED TAMAMLANDI';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Keys: %', v_key_count;
    RAISE NOTICE 'English Values: %', v_en_count;
    RAISE NOTICE 'Turkish Values: %', v_tr_count;
    RAISE NOTICE '================================================';
END $$;

-- ============================================================================
-- ÖZET
-- ============================================================================
--
-- Key Pattern: ui.{element-type}.{code}
--
-- Menu Groups (4):
--   - platform, companies, tenants, audit
--
-- Menus (8):
--   - system, rbac (Platform)
--   - companies, company-users (Companies)
--   - tenants, tenant-users, tenant-settings (Tenants)
--   - audit-logs (Audit)
--
-- Submenus (6):
--   - health, logs, system-settings (System)
--   - menus, roles, permissions (RBAC)
--
-- Pages (15):
--   - Platform: health, logs, system-settings, menu-management, roles, permissions
--   - Companies: companies, company-detail, company-users
--   - Tenants: tenants, tenant-detail, tenant-users, tenant-user-detail, tenant-settings
--   - Audit: audit-logs, audit-log-detail
--
-- Contexts (6):
--   - Company Detail: company-info, company-tenants, company-users
--   - Tenant Detail: tenant-info, tenant-users, tenant-settings
--
-- ============================================================================
