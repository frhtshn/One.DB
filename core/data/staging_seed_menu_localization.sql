-- ================================================================
-- NUCLEO PLATFORM - MENU LOCALIZATION SEED
-- ================================================================
-- seed_presentation.sql ile birebir uyumlu localization key'ler.
-- Her key = seed_presentation.sql'deki title_localization_key veya label_localization_key.
-- ================================================================
-- CALISTIRMA SIRASI: Bu dosya seed_presentation.sql'den ONCE calistirilmali.
-- ================================================================
-- Key Pattern: ui.{element-type}.{code}
-- Element Types: menu-group, menu, submenu, page, tab, context
-- ================================================================
-- Toplam: 115 key (4 group + 7 menu + 10 submenu + 34 page + 23 tab + 37 context)
-- ================================================================

-- ================================================================
-- 1. LOCALIZATION KEYS (115)
-- ================================================================

INSERT INTO catalog.localization_keys (localization_key, domain, category, description) VALUES

-- ----------------------------------------------------------------
-- MENU GROUPS (4)
-- ----------------------------------------------------------------
('ui.menu-group.platform', 'ui', 'menu', 'Platform menu grubu'),
('ui.menu-group.companies', 'ui', 'menu', 'Companies menu grubu'),
('ui.menu-group.tenants', 'ui', 'menu', 'Tenants menu grubu'),
('ui.menu-group.audit', 'ui', 'menu', 'Audit menu grubu'),

-- ----------------------------------------------------------------
-- MENUS (7)
-- ----------------------------------------------------------------
('ui.menu.system', 'ui', 'menu', 'System menusu'),
('ui.menu.rbac', 'ui', 'menu', 'RBAC menusu'),
('ui.menu.catalog', 'ui', 'menu', 'Catalog menusu'),
('ui.menu.companies', 'ui', 'menu', 'Companies menusu'),
('ui.menu.tenants', 'ui', 'menu', 'Tenants menusu'),
('ui.menu.users', 'ui', 'menu', 'Users menusu'),
('ui.menu.audit-logs', 'ui', 'menu', 'Audit Logs menusu'),

-- ----------------------------------------------------------------
-- SUBMENUS (10)
-- ----------------------------------------------------------------
-- System
('ui.submenu.monitoring', 'ui', 'menu', 'Monitoring alt menusu'),
('ui.submenu.localization', 'ui', 'menu', 'Localization alt menusu'),
-- RBAC
('ui.submenu.roles', 'ui', 'menu', 'Roles alt menusu'),
('ui.submenu.permissions', 'ui', 'menu', 'Permissions alt menusu'),
('ui.submenu.menus', 'ui', 'menu', 'Menu Management alt menusu'),
('ui.submenu.permission-templates', 'ui', 'menu', 'Permission Templates alt menusu'),
-- Catalog
('ui.submenu.providers', 'ui', 'menu', 'Providers alt menusu'),
('ui.submenu.payment-methods', 'ui', 'menu', 'Payment Methods alt menusu'),
('ui.submenu.compliance', 'ui', 'menu', 'Compliance alt menusu'),
('ui.submenu.uikit', 'ui', 'menu', 'UI Kit alt menusu'),

-- ----------------------------------------------------------------
-- PAGES - Standalone (8)
-- ----------------------------------------------------------------
('ui.page.dashboard', 'ui', 'page', 'Dashboard sayfasi'),
('ui.page.company-detail', 'ui', 'page', 'Company detail sayfasi'),
('ui.page.tenant-detail', 'ui', 'page', 'Tenant detail sayfasi'),
('ui.page.user-detail', 'ui', 'page', 'User detail sayfasi'),
('ui.page.role-detail', 'ui', 'page', 'Role detail sayfasi'),
('ui.page.provider-detail', 'ui', 'page', 'Provider detail sayfasi'),
('ui.page.nav-template-detail', 'ui', 'page', 'Nav template detail sayfasi'),
('ui.page.permission-template-detail', 'ui', 'page', 'Permission template detail sayfasi'),

-- ----------------------------------------------------------------
-- PAGES - System (4)
-- ----------------------------------------------------------------
('ui.page.error-logs', 'ui', 'page', 'Error logs sayfasi'),
('ui.page.dead-letters', 'ui', 'page', 'Dead letters sayfasi'),
('ui.page.languages', 'ui', 'page', 'Languages sayfasi'),
('ui.page.localization-keys', 'ui', 'page', 'Localization keys sayfasi'),

-- ----------------------------------------------------------------
-- PAGES - RBAC (4)
-- ----------------------------------------------------------------
('ui.page.roles', 'ui', 'page', 'Roles sayfasi'),
('ui.page.permissions', 'ui', 'page', 'Permissions sayfasi'),
('ui.page.menu-management', 'ui', 'page', 'Menu management sayfasi'),
('ui.page.permission-templates', 'ui', 'page', 'Permission templates sayfasi'),

-- ----------------------------------------------------------------
-- PAGES - Catalog (14)
-- ----------------------------------------------------------------
('ui.page.providers', 'ui', 'page', 'Providers sayfasi'),
('ui.page.provider-types', 'ui', 'page', 'Provider types sayfasi'),
('ui.page.currencies', 'ui', 'page', 'Currencies sayfasi'),
('ui.page.cryptocurrencies', 'ui', 'page', 'Cryptocurrencies sayfasi'),
('ui.page.payment-methods', 'ui', 'page', 'Payment methods sayfasi'),
('ui.page.jurisdictions', 'ui', 'page', 'Jurisdictions sayfasi'),
('ui.page.kyc-policies', 'ui', 'page', 'KYC policies sayfasi'),
('ui.page.kyc-doc-requirements', 'ui', 'page', 'KYC document requirements sayfasi'),
('ui.page.kyc-level-requirements', 'ui', 'page', 'KYC level requirements sayfasi'),
('ui.page.rg-policies', 'ui', 'page', 'Responsible gaming policies sayfasi'),
('ui.page.themes', 'ui', 'page', 'Themes sayfasi'),
('ui.page.nav-templates', 'ui', 'page', 'Navigation templates sayfasi'),
('ui.page.widgets', 'ui', 'page', 'Widgets sayfasi'),
('ui.page.ui-positions', 'ui', 'page', 'UI positions sayfasi'),

-- ----------------------------------------------------------------
-- PAGES - Companies, Tenants, Audit (4)
-- ----------------------------------------------------------------
('ui.page.companies', 'ui', 'page', 'Companies sayfasi'),
('ui.page.tenants', 'ui', 'page', 'Tenants sayfasi'),
('ui.page.users', 'ui', 'page', 'Users sayfasi'),
('ui.page.audit-logs', 'ui', 'page', 'Audit logs sayfasi'),

-- ----------------------------------------------------------------
-- TABS (23)
-- ----------------------------------------------------------------
-- Company Detail (2)
('ui.tab.company-details', 'ui', 'tab', 'Company details sekmesi'),
('ui.tab.company-password-policy', 'ui', 'tab', 'Company password policy sekmesi'),
-- Tenant Detail (4)
('ui.tab.tenant-details', 'ui', 'tab', 'Tenant details sekmesi'),
('ui.tab.tenant-settings', 'ui', 'tab', 'Tenant settings sekmesi'),
('ui.tab.tenant-regional', 'ui', 'tab', 'Tenant regional sekmesi'),
('ui.tab.tenant-presentation', 'ui', 'tab', 'Tenant presentation sekmesi'),
-- User Detail (4)
('ui.tab.user-details', 'ui', 'tab', 'User details sekmesi'),
('ui.tab.user-roles', 'ui', 'tab', 'User roles sekmesi'),
('ui.tab.user-permissions', 'ui', 'tab', 'User permissions sekmesi'),
('ui.tab.user-permission-templates', 'ui', 'tab', 'User permission templates sekmesi'),
-- Role Detail (2)
('ui.tab.role-details', 'ui', 'tab', 'Role details sekmesi'),
('ui.tab.role-permissions', 'ui', 'tab', 'Role permissions sekmesi'),
-- Provider Detail (2)
('ui.tab.provider-details', 'ui', 'tab', 'Provider details sekmesi'),
('ui.tab.provider-settings', 'ui', 'tab', 'Provider settings sekmesi'),
-- Nav Template Detail (2)
('ui.tab.nav-template-details', 'ui', 'tab', 'Nav template details sekmesi'),
('ui.tab.nav-template-items', 'ui', 'tab', 'Nav template items sekmesi'),
-- Permission Template Detail (3)
('ui.tab.template-details', 'ui', 'tab', 'Template details sekmesi'),
('ui.tab.template-permissions', 'ui', 'tab', 'Template permissions sekmesi'),
('ui.tab.template-assignments', 'ui', 'tab', 'Template assignments sekmesi'),
-- Audit Logs (2)
('ui.tab.audit-search', 'ui', 'tab', 'Audit search sekmesi'),
('ui.tab.audit-detail', 'ui', 'tab', 'Audit detail sekmesi'),
-- Localization Keys (2)
('ui.tab.localization-keys', 'ui', 'tab', 'Localization keys sekmesi'),
('ui.tab.localization-values', 'ui', 'tab', 'Localization values sekmesi'),

-- ----------------------------------------------------------------
-- CONTEXTS - List Pages (17)
-- ----------------------------------------------------------------
('ui.context.company-create', 'ui', 'context', 'Company create button'),
('ui.context.tenant-create', 'ui', 'context', 'Tenant create button'),
('ui.context.user-create', 'ui', 'context', 'User create button'),
('ui.context.provider-create', 'ui', 'context', 'Provider create button'),
('ui.context.provider-type-create', 'ui', 'context', 'Provider type create button'),
('ui.context.currency-create', 'ui', 'context', 'Currency create button'),
('ui.context.cryptocurrency-create', 'ui', 'context', 'Cryptocurrency create button'),
('ui.context.payment-method-create', 'ui', 'context', 'Payment method create button'),
('ui.context.jurisdiction-create', 'ui', 'context', 'Jurisdiction create button'),
('ui.context.kyc-policy-create', 'ui', 'context', 'KYC policy create button'),
('ui.context.kyc-doc-req-create', 'ui', 'context', 'KYC doc requirement create button'),
('ui.context.kyc-level-req-create', 'ui', 'context', 'KYC level requirement create button'),
('ui.context.rg-policy-create', 'ui', 'context', 'RG policy create button'),
('ui.context.theme-create', 'ui', 'context', 'Theme create button'),
('ui.context.nav-template-create', 'ui', 'context', 'Nav template create button'),
('ui.context.widget-create', 'ui', 'context', 'Widget create button'),
('ui.context.ui-position-create', 'ui', 'context', 'UI position create button'),

-- ----------------------------------------------------------------
-- CONTEXTS - Company Detail (3)
-- ----------------------------------------------------------------
('ui.context.company-edit', 'ui', 'context', 'Company edit button'),
('ui.context.company-delete', 'ui', 'context', 'Company delete action'),
('ui.context.company-pp-edit', 'ui', 'context', 'Company password policy edit button'),

-- ----------------------------------------------------------------
-- CONTEXTS - Tenant Detail (6)
-- ----------------------------------------------------------------
('ui.context.tenant-edit', 'ui', 'context', 'Tenant edit button'),
('ui.context.tenant-delete', 'ui', 'context', 'Tenant delete action'),
('ui.context.tenant-settings-edit', 'ui', 'context', 'Tenant settings edit button'),
('ui.context.tenant-currencies', 'ui', 'context', 'Tenant currencies select'),
('ui.context.tenant-languages', 'ui', 'context', 'Tenant languages select'),
('ui.context.tenant-crypto', 'ui', 'context', 'Tenant crypto select'),

-- ----------------------------------------------------------------
-- CONTEXTS - User Detail (7)
-- ----------------------------------------------------------------
('ui.context.user-email', 'ui', 'context', 'User email field (PII)'),
('ui.context.user-username', 'ui', 'context', 'User username field (PII)'),
('ui.context.user-first-name', 'ui', 'context', 'User first name field (PII)'),
('ui.context.user-last-name', 'ui', 'context', 'User last name field (PII)'),
('ui.context.user-edit', 'ui', 'context', 'User edit button'),
('ui.context.user-delete', 'ui', 'context', 'User delete action'),
('ui.context.user-deny-permission', 'ui', 'context', 'User deny permission action'),

-- ----------------------------------------------------------------
-- CONTEXTS - Provider Detail (2)
-- ----------------------------------------------------------------
('ui.context.provider-edit', 'ui', 'context', 'Provider edit button'),
('ui.context.provider-delete', 'ui', 'context', 'Provider delete action'),

-- ----------------------------------------------------------------
-- CONTEXTS - Nav Template Detail (1)
-- ----------------------------------------------------------------
('ui.context.nav-template-edit', 'ui', 'context', 'Nav template edit button'),

-- ----------------------------------------------------------------
-- CONTEXTS - Audit (1)
-- ----------------------------------------------------------------
('ui.context.audit-view', 'ui', 'context', 'Audit view action')

ON CONFLICT (localization_key) DO NOTHING;

-- ================================================================
-- 2. LOCALIZATION VALUES - ENGLISH (en)
-- ================================================================

INSERT INTO catalog.localization_values (localization_key_id, language_code, localized_text, created_at)
SELECT k.id, 'en', v.text, NOW()
FROM catalog.localization_keys k
JOIN (VALUES
    -- Menu Groups (4)
    ('ui.menu-group.platform', 'Platform'),
    ('ui.menu-group.companies', 'Company Management'),
    ('ui.menu-group.tenants', 'Tenant Management'),
    ('ui.menu-group.audit', 'Audit & Compliance'),

    -- Menus (7)
    ('ui.menu.system', 'System'),
    ('ui.menu.rbac', 'Access Control'),
    ('ui.menu.catalog', 'Catalog'),
    ('ui.menu.companies', 'Companies'),
    ('ui.menu.tenants', 'Tenants'),
    ('ui.menu.users', 'Users'),
    ('ui.menu.audit-logs', 'Audit Logs'),

    -- Submenus (10)
    ('ui.submenu.monitoring', 'Monitoring'),
    ('ui.submenu.localization', 'Localization'),
    ('ui.submenu.roles', 'Roles'),
    ('ui.submenu.permissions', 'Permissions'),
    ('ui.submenu.menus', 'Menu Management'),
    ('ui.submenu.permission-templates', 'Permission Templates'),
    ('ui.submenu.providers', 'Providers'),
    ('ui.submenu.payment-methods', 'Payment Methods'),
    ('ui.submenu.compliance', 'Compliance'),
    ('ui.submenu.uikit', 'UI Kit'),

    -- Pages - Standalone (8)
    ('ui.page.dashboard', 'Dashboard'),
    ('ui.page.company-detail', 'Company Details'),
    ('ui.page.tenant-detail', 'Tenant Details'),
    ('ui.page.user-detail', 'User Details'),
    ('ui.page.role-detail', 'Role Details'),
    ('ui.page.provider-detail', 'Provider Details'),
    ('ui.page.nav-template-detail', 'Navigation Template Details'),
    ('ui.page.permission-template-detail', 'Permission Template Details'),

    -- Pages - System (4)
    ('ui.page.error-logs', 'Error Logs'),
    ('ui.page.dead-letters', 'Dead Letters'),
    ('ui.page.languages', 'Languages'),
    ('ui.page.localization-keys', 'Localization Keys'),

    -- Pages - RBAC (4)
    ('ui.page.roles', 'Roles'),
    ('ui.page.permissions', 'Permissions'),
    ('ui.page.menu-management', 'Menu Management'),
    ('ui.page.permission-templates', 'Permission Templates'),

    -- Pages - Catalog (14)
    ('ui.page.providers', 'Providers'),
    ('ui.page.provider-types', 'Provider Types'),
    ('ui.page.currencies', 'Currencies'),
    ('ui.page.cryptocurrencies', 'Cryptocurrencies'),
    ('ui.page.payment-methods', 'Payment Methods'),
    ('ui.page.jurisdictions', 'Jurisdictions'),
    ('ui.page.kyc-policies', 'KYC Policies'),
    ('ui.page.kyc-doc-requirements', 'KYC Document Requirements'),
    ('ui.page.kyc-level-requirements', 'KYC Level Requirements'),
    ('ui.page.rg-policies', 'Responsible Gaming Policies'),
    ('ui.page.themes', 'Themes'),
    ('ui.page.nav-templates', 'Navigation Templates'),
    ('ui.page.widgets', 'Widgets'),
    ('ui.page.ui-positions', 'UI Positions'),

    -- Pages - Companies, Tenants, Audit (4)
    ('ui.page.companies', 'Companies'),
    ('ui.page.tenants', 'Tenants'),
    ('ui.page.users', 'Users'),
    ('ui.page.audit-logs', 'Audit Logs'),

    -- Tabs (23)
    ('ui.tab.company-details', 'Details'),
    ('ui.tab.company-password-policy', 'Password Policy'),
    ('ui.tab.tenant-details', 'Details'),
    ('ui.tab.tenant-settings', 'Settings'),
    ('ui.tab.tenant-regional', 'Regional'),
    ('ui.tab.tenant-presentation', 'Presentation'),
    ('ui.tab.user-details', 'Details'),
    ('ui.tab.user-roles', 'Roles'),
    ('ui.tab.user-permissions', 'Permissions'),
    ('ui.tab.user-permission-templates', 'Permission Templates'),
    ('ui.tab.role-details', 'Details'),
    ('ui.tab.role-permissions', 'Permissions'),
    ('ui.tab.provider-details', 'Details'),
    ('ui.tab.provider-settings', 'Settings'),
    ('ui.tab.nav-template-details', 'Details'),
    ('ui.tab.nav-template-items', 'Items'),
    ('ui.tab.template-details', 'Details'),
    ('ui.tab.template-permissions', 'Permissions'),
    ('ui.tab.template-assignments', 'Assignments'),
    ('ui.tab.audit-search', 'Search'),
    ('ui.tab.audit-detail', 'Detail'),
    ('ui.tab.localization-keys', 'Keys'),
    ('ui.tab.localization-values', 'Values'),

    -- Contexts - List Pages (17)
    ('ui.context.company-create', 'Create Company'),
    ('ui.context.tenant-create', 'Create Tenant'),
    ('ui.context.user-create', 'Create User'),
    ('ui.context.provider-create', 'Create Provider'),
    ('ui.context.provider-type-create', 'Create Provider Type'),
    ('ui.context.currency-create', 'Create Currency'),
    ('ui.context.cryptocurrency-create', 'Create Cryptocurrency'),
    ('ui.context.payment-method-create', 'Create Payment Method'),
    ('ui.context.jurisdiction-create', 'Create Jurisdiction'),
    ('ui.context.kyc-policy-create', 'Create KYC Policy'),
    ('ui.context.kyc-doc-req-create', 'Create Document Requirement'),
    ('ui.context.kyc-level-req-create', 'Create Level Requirement'),
    ('ui.context.rg-policy-create', 'Create RG Policy'),
    ('ui.context.theme-create', 'Create Theme'),
    ('ui.context.nav-template-create', 'Create Navigation Template'),
    ('ui.context.widget-create', 'Create Widget'),
    ('ui.context.ui-position-create', 'Create UI Position'),

    -- Contexts - Company Detail (3)
    ('ui.context.company-edit', 'Edit Company'),
    ('ui.context.company-delete', 'Delete Company'),
    ('ui.context.company-pp-edit', 'Edit Password Policy'),

    -- Contexts - Tenant Detail (6)
    ('ui.context.tenant-edit', 'Edit Tenant'),
    ('ui.context.tenant-delete', 'Delete Tenant'),
    ('ui.context.tenant-settings-edit', 'Edit Settings'),
    ('ui.context.tenant-currencies', 'Currencies'),
    ('ui.context.tenant-languages', 'Languages'),
    ('ui.context.tenant-crypto', 'Cryptocurrencies'),

    -- Contexts - User Detail (7)
    ('ui.context.user-email', 'Email'),
    ('ui.context.user-username', 'Username'),
    ('ui.context.user-first-name', 'First Name'),
    ('ui.context.user-last-name', 'Last Name'),
    ('ui.context.user-edit', 'Edit User'),
    ('ui.context.user-delete', 'Delete User'),
    ('ui.context.user-deny-permission', 'Deny Permission'),

    -- Contexts - Provider Detail (2)
    ('ui.context.provider-edit', 'Edit Provider'),
    ('ui.context.provider-delete', 'Delete Provider'),

    -- Contexts - Nav Template Detail (1)
    ('ui.context.nav-template-edit', 'Edit Template'),

    -- Contexts - Audit (1)
    ('ui.context.audit-view', 'View Details')
) AS v(key, text) ON k.localization_key = v.key
ON CONFLICT DO NOTHING;

-- ================================================================
-- 3. LOCALIZATION VALUES - TURKISH (tr)
-- ================================================================

INSERT INTO catalog.localization_values (localization_key_id, language_code, localized_text, created_at)
SELECT k.id, 'tr', v.text, NOW()
FROM catalog.localization_keys k
JOIN (VALUES
    -- Menu Groups (4)
    ('ui.menu-group.platform', 'Platform'),
    ('ui.menu-group.companies', 'Sirket Yonetimi'),
    ('ui.menu-group.tenants', 'Tenant Yonetimi'),
    ('ui.menu-group.audit', 'Denetim'),

    -- Menus (7)
    ('ui.menu.system', 'Sistem'),
    ('ui.menu.rbac', 'Erisim Kontrolu'),
    ('ui.menu.catalog', 'Katalog'),
    ('ui.menu.companies', 'Sirketler'),
    ('ui.menu.tenants', 'Tenantlar'),
    ('ui.menu.users', 'Kullanicilar'),
    ('ui.menu.audit-logs', 'Denetim Kayitlari'),

    -- Submenus (10)
    ('ui.submenu.monitoring', 'Izleme'),
    ('ui.submenu.localization', 'Dil Cevirileri'),
    ('ui.submenu.roles', 'Roller'),
    ('ui.submenu.permissions', 'Yetkiler'),
    ('ui.submenu.menus', 'Menu Yonetimi'),
    ('ui.submenu.permission-templates', 'Yetki Sablonlari'),
    ('ui.submenu.providers', 'Saglayicilar'),
    ('ui.submenu.payment-methods', 'Odeme Yontemleri'),
    ('ui.submenu.compliance', 'Uyumluluk'),
    ('ui.submenu.uikit', 'UI Kit'),

    -- Pages - Standalone (8)
    ('ui.page.dashboard', 'Dashboard'),
    ('ui.page.company-detail', 'Sirket Detayi'),
    ('ui.page.tenant-detail', 'Tenant Detayi'),
    ('ui.page.user-detail', 'Kullanici Detayi'),
    ('ui.page.role-detail', 'Rol Detayi'),
    ('ui.page.provider-detail', 'Provider Detayi'),
    ('ui.page.nav-template-detail', 'Nav Sablon Detayi'),
    ('ui.page.permission-template-detail', 'Yetki Sablonu Detayi'),

    -- Pages - System (4)
    ('ui.page.error-logs', 'Hata Kayitlari'),
    ('ui.page.dead-letters', 'Dead Letters'),
    ('ui.page.languages', 'Diller'),
    ('ui.page.localization-keys', 'Lokalizasyon Anahtarlari'),

    -- Pages - RBAC (4)
    ('ui.page.roles', 'Roller'),
    ('ui.page.permissions', 'Yetkiler'),
    ('ui.page.menu-management', 'Menu Yonetimi'),
    ('ui.page.permission-templates', 'Yetki Sablonlari'),

    -- Pages - Catalog (14)
    ('ui.page.providers', 'Saglayicilar'),
    ('ui.page.provider-types', 'Saglayici Tipleri'),
    ('ui.page.currencies', 'Para Birimleri'),
    ('ui.page.cryptocurrencies', 'Kripto Para Birimleri'),
    ('ui.page.payment-methods', 'Odeme Yontemleri'),
    ('ui.page.jurisdictions', 'Yargi Alanlari'),
    ('ui.page.kyc-policies', 'KYC Politikalari'),
    ('ui.page.kyc-doc-requirements', 'KYC Dokuman Gereksinimleri'),
    ('ui.page.kyc-level-requirements', 'KYC Seviye Gereksinimleri'),
    ('ui.page.rg-policies', 'Sorumlu Oyun Politikalari'),
    ('ui.page.themes', 'Temalar'),
    ('ui.page.nav-templates', 'Nav Sablonlari'),
    ('ui.page.widgets', 'Widgetlar'),
    ('ui.page.ui-positions', 'UI Pozisyonlari'),

    -- Pages - Companies, Tenants, Audit (4)
    ('ui.page.companies', 'Sirketler'),
    ('ui.page.tenants', 'Tenantlar'),
    ('ui.page.users', 'Kullanicilar'),
    ('ui.page.audit-logs', 'Denetim Kayitlari'),

    -- Tabs (23)
    ('ui.tab.company-details', 'Detaylar'),
    ('ui.tab.company-password-policy', 'Sifre Politikasi'),
    ('ui.tab.tenant-details', 'Detaylar'),
    ('ui.tab.tenant-settings', 'Ayarlar'),
    ('ui.tab.tenant-regional', 'Bolgesel'),
    ('ui.tab.tenant-presentation', 'Sunum'),
    ('ui.tab.user-details', 'Detaylar'),
    ('ui.tab.user-roles', 'Roller'),
    ('ui.tab.user-permissions', 'Yetkiler'),
    ('ui.tab.user-permission-templates', 'Yetki Sablonlari'),
    ('ui.tab.role-details', 'Detaylar'),
    ('ui.tab.role-permissions', 'Yetkiler'),
    ('ui.tab.provider-details', 'Detaylar'),
    ('ui.tab.provider-settings', 'Ayarlar'),
    ('ui.tab.nav-template-details', 'Detaylar'),
    ('ui.tab.nav-template-items', 'Ogeler'),
    ('ui.tab.template-details', 'Detaylar'),
    ('ui.tab.template-permissions', 'Yetkiler'),
    ('ui.tab.template-assignments', 'Atamalar'),
    ('ui.tab.audit-search', 'Arama'),
    ('ui.tab.audit-detail', 'Detay'),
    ('ui.tab.localization-keys', 'Anahtarlar'),
    ('ui.tab.localization-values', 'Degerler'),

    -- Contexts - List Pages (17)
    ('ui.context.company-create', 'Sirket Olustur'),
    ('ui.context.tenant-create', 'Tenant Olustur'),
    ('ui.context.user-create', 'Kullanici Olustur'),
    ('ui.context.provider-create', 'Provider Olustur'),
    ('ui.context.provider-type-create', 'Provider Tipi Olustur'),
    ('ui.context.currency-create', 'Para Birimi Olustur'),
    ('ui.context.cryptocurrency-create', 'Kripto Para Birimi Olustur'),
    ('ui.context.payment-method-create', 'Odeme Yontemi Olustur'),
    ('ui.context.jurisdiction-create', 'Yargi Alani Olustur'),
    ('ui.context.kyc-policy-create', 'KYC Politikasi Olustur'),
    ('ui.context.kyc-doc-req-create', 'KYC Dokuman Gereksinimi Olustur'),
    ('ui.context.kyc-level-req-create', 'KYC Seviye Gereksinimi Olustur'),
    ('ui.context.rg-policy-create', 'Sorumlu Oyun Politikasi Olustur'),
    ('ui.context.theme-create', 'Tema Olustur'),
    ('ui.context.nav-template-create', 'Nav Sablon Olustur'),
    ('ui.context.widget-create', 'Widget Olustur'),
    ('ui.context.ui-position-create', 'UI Pozisyon Olustur'),

    -- Contexts - Company Detail (3)
    ('ui.context.company-edit', 'Sirketi Duzenle'),
    ('ui.context.company-delete', 'Sirketi Sil'),
    ('ui.context.company-pp-edit', 'Sifre Politikasini Duzenle'),

    -- Contexts - Tenant Detail (6)
    ('ui.context.tenant-edit', 'Tenanti Duzenle'),
    ('ui.context.tenant-delete', 'Tenanti Sil'),
    ('ui.context.tenant-settings-edit', 'Ayarlari Duzenle'),
    ('ui.context.tenant-currencies', 'Para Birimleri'),
    ('ui.context.tenant-languages', 'Diller'),
    ('ui.context.tenant-crypto', 'Kripto Para Birimleri'),

    -- Contexts - User Detail (7)
    ('ui.context.user-email', 'Email'),
    ('ui.context.user-username', 'Kullanici Adi'),
    ('ui.context.user-first-name', 'Ad'),
    ('ui.context.user-last-name', 'Soyad'),
    ('ui.context.user-edit', 'Kullaniciyi Duzenle'),
    ('ui.context.user-delete', 'Kullaniciyi Sil'),
    ('ui.context.user-deny-permission', 'Yetkiyi Reddet'),

    -- Contexts - Provider Detail (2)
    ('ui.context.provider-edit', 'Provideri Duzenle'),
    ('ui.context.provider-delete', 'Provideri Sil'),

    -- Contexts - Nav Template Detail (1)
    ('ui.context.nav-template-edit', 'Sablonu Duzenle'),

    -- Contexts - Audit (1)
    ('ui.context.audit-view', 'Detay Gor')
) AS v(key, text) ON k.localization_key = v.key
ON CONFLICT DO NOTHING;

-- ================================================================
-- 4. DOGRULAMA
-- ================================================================

DO $$
DECLARE
    v_key_count INT;
    v_en_count INT;
    v_tr_count INT;
BEGIN
    SELECT COUNT(*) INTO v_key_count
    FROM catalog.localization_keys
    WHERE localization_key LIKE 'ui.menu-group.%'
       OR localization_key LIKE 'ui.menu.%'
       OR localization_key LIKE 'ui.submenu.%'
       OR localization_key LIKE 'ui.page.%'
       OR localization_key LIKE 'ui.tab.%'
       OR localization_key LIKE 'ui.context.%';

    SELECT COUNT(*) INTO v_en_count
    FROM catalog.localization_values lv
    JOIN catalog.localization_keys lk ON lv.localization_key_id = lk.id
    WHERE lv.language_code = 'en'
      AND (lk.localization_key LIKE 'ui.menu-group.%'
           OR lk.localization_key LIKE 'ui.menu.%'
           OR lk.localization_key LIKE 'ui.submenu.%'
           OR lk.localization_key LIKE 'ui.page.%'
           OR lk.localization_key LIKE 'ui.tab.%'
           OR lk.localization_key LIKE 'ui.context.%');

    SELECT COUNT(*) INTO v_tr_count
    FROM catalog.localization_values lv
    JOIN catalog.localization_keys lk ON lv.localization_key_id = lk.id
    WHERE lv.language_code = 'tr'
      AND (lk.localization_key LIKE 'ui.menu-group.%'
           OR lk.localization_key LIKE 'ui.menu.%'
           OR lk.localization_key LIKE 'ui.submenu.%'
           OR lk.localization_key LIKE 'ui.page.%'
           OR lk.localization_key LIKE 'ui.tab.%'
           OR lk.localization_key LIKE 'ui.context.%');

    RAISE NOTICE '================================================';
    RAISE NOTICE 'MENU LOCALIZATION SEED TAMAMLANDI';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Keys: % (beklenen: 115)', v_key_count;
    RAISE NOTICE 'English Values: % (beklenen: 115)', v_en_count;
    RAISE NOTICE 'Turkish Values: % (beklenen: 115)', v_tr_count;
    RAISE NOTICE '================================================';
END $$;
