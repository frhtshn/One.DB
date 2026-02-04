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
-- MENU GROUPS (10)
-- ============================================================================
('ui.menu-group.platform', 'ui', 'menu', 'Platform menü grubu'),
('ui.menu-group.companies', 'ui', 'menu', 'Companies menü grubu'),
('ui.menu-group.tenants', 'ui', 'menu', 'Tenants menü grubu'),
('ui.menu-group.players', 'ui', 'menu', 'Players menü grubu'),
('ui.menu-group.games', 'ui', 'menu', 'Games menü grubu'),
('ui.menu-group.finance', 'ui', 'menu', 'Finance menü grubu'),
('ui.menu-group.bonuses', 'ui', 'menu', 'Bonuses menü grubu'),
('ui.menu-group.affiliate', 'ui', 'menu', 'Affiliate menü grubu'),
('ui.menu-group.reports', 'ui', 'menu', 'Reports menü grubu'),
('ui.menu-group.audit', 'ui', 'menu', 'Audit menü grubu'),

-- ============================================================================
-- MENUS - Platform
-- ============================================================================
('ui.menu.system', 'ui', 'menu', 'System menüsü'),
('ui.menu.rbac', 'ui', 'menu', 'RBAC menüsü'),
('ui.menu.catalog', 'ui', 'menu', 'Catalog menüsü'),

-- ============================================================================
-- MENUS - Companies
-- ============================================================================
('ui.menu.companies', 'ui', 'menu', 'Şirketler menüsü'),
('ui.menu.company-users', 'ui', 'menu', 'Company kullanıcıları menüsü'),
('ui.menu.company-billing', 'ui', 'menu', 'Company billing menüsü'),

-- ============================================================================
-- MENUS - Tenants
-- ============================================================================
('ui.menu.tenants', 'ui', 'menu', 'Tenantlar menüsü'),
('ui.menu.tenant-users', 'ui', 'menu', 'Tenant kullanıcıları menüsü'),
('ui.menu.tenant-settings', 'ui', 'menu', 'Tenant ayarları menüsü'),
('ui.menu.tenant-content', 'ui', 'menu', 'Tenant content menüsü'),

-- ============================================================================
-- MENUS - Players
-- ============================================================================
('ui.menu.player-list', 'ui', 'menu', 'Player listesi menüsü'),
('ui.menu.player-kyc', 'ui', 'menu', 'Player KYC menüsü'),
('ui.menu.player-rg', 'ui', 'menu', 'Player responsible gaming menüsü'),

-- ============================================================================
-- MENUS - Games
-- ============================================================================
('ui.menu.game-providers', 'ui', 'menu', 'Game providers menüsü'),
('ui.menu.game-list', 'ui', 'menu', 'Game listesi menüsü'),
('ui.menu.game-categories', 'ui', 'menu', 'Game kategorileri menüsü'),
('ui.menu.game-lobby', 'ui', 'menu', 'Game lobby menüsü'),

-- ============================================================================
-- MENUS - Finance
-- ============================================================================
('ui.menu.finance-transactions', 'ui', 'menu', 'Finance transactions menüsü'),
('ui.menu.finance-deposits', 'ui', 'menu', 'Finance deposits menüsü'),
('ui.menu.finance-withdrawals', 'ui', 'menu', 'Finance withdrawals menüsü'),
('ui.menu.finance-adjustments', 'ui', 'menu', 'Finance adjustments menüsü'),
('ui.menu.finance-payment-methods', 'ui', 'menu', 'Finance payment methods menüsü'),

-- ============================================================================
-- MENUS - Bonuses
-- ============================================================================
('ui.menu.bonus-list', 'ui', 'menu', 'Bonus listesi menüsü'),
('ui.menu.bonus-campaigns', 'ui', 'menu', 'Bonus campaigns menüsü'),
('ui.menu.promo-codes', 'ui', 'menu', 'Promo codes menüsü'),
('ui.menu.bonus-templates', 'ui', 'menu', 'Bonus templates menüsü'),

-- ============================================================================
-- MENUS - Affiliate
-- ============================================================================
('ui.menu.affiliate-list', 'ui', 'menu', 'Affiliate listesi menüsü'),
('ui.menu.affiliate-commissions', 'ui', 'menu', 'Affiliate commissions menüsü'),
('ui.menu.affiliate-reports', 'ui', 'menu', 'Affiliate reports menüsü'),

-- ============================================================================
-- MENUS - Reports
-- ============================================================================
('ui.menu.report-dashboard', 'ui', 'menu', 'Report dashboard menüsü'),
('ui.menu.report-players', 'ui', 'menu', 'Report players menüsü'),
('ui.menu.report-games', 'ui', 'menu', 'Report games menüsü'),
('ui.menu.report-financial', 'ui', 'menu', 'Report financial menüsü'),
('ui.menu.report-risk', 'ui', 'menu', 'Report risk menüsü'),

-- ============================================================================
-- MENUS - Audit
-- ============================================================================
('ui.menu.audit-logs', 'ui', 'menu', 'Audit logs menüsü'),
('ui.menu.audit-kyc', 'ui', 'menu', 'Audit KYC menüsü'),
('ui.menu.audit-aml', 'ui', 'menu', 'Audit AML menüsü'),
('ui.menu.audit-fraud', 'ui', 'menu', 'Audit fraud menüsü'),

-- ============================================================================
-- SUBMENUS - System
-- ============================================================================
('ui.submenu.health', 'ui', 'menu', 'Health check alt menüsü'),
('ui.submenu.logs', 'ui', 'menu', 'Logs alt menüsü'),
('ui.submenu.system-settings', 'ui', 'menu', 'System settings alt menüsü'),

-- ============================================================================
-- SUBMENUS - RBAC
-- ============================================================================
('ui.submenu.menus', 'ui', 'menu', 'Menü yönetimi alt menüsü'),
('ui.submenu.roles', 'ui', 'menu', 'Roller alt menüsü'),
('ui.submenu.permissions', 'ui', 'menu', 'Permissionlar alt menüsü'),

-- ============================================================================
-- SUBMENUS - Catalog
-- ============================================================================
('ui.submenu.providers', 'ui', 'menu', 'Providers alt menüsü'),
('ui.submenu.games-catalog', 'ui', 'menu', 'Games catalog alt menüsü'),
('ui.submenu.payment-methods', 'ui', 'menu', 'Payment methods alt menüsü'),
('ui.submenu.compliance', 'ui', 'menu', 'Compliance alt menüsü'),
('ui.submenu.uikit', 'ui', 'menu', 'UIKit alt menüsü'),
('ui.submenu.reference-data', 'ui', 'menu', 'Reference data alt menüsü'),

-- ============================================================================
-- PAGES - Platform
-- ============================================================================
('ui.page.health', 'ui', 'page', 'Health check sayfası'),
('ui.page.logs', 'ui', 'page', 'Logs sayfası'),
('ui.page.system-settings', 'ui', 'page', 'System settings sayfası'),
('ui.page.menu-management', 'ui', 'page', 'Menü yönetimi sayfası'),
('ui.page.roles', 'ui', 'page', 'Roller sayfası'),
('ui.page.permissions', 'ui', 'page', 'Permissionlar sayfası'),
('ui.page.providers', 'ui', 'page', 'Providers sayfası'),
('ui.page.games-catalog', 'ui', 'page', 'Games catalog sayfası'),
('ui.page.payment-methods', 'ui', 'page', 'Payment methods sayfası'),
('ui.page.compliance', 'ui', 'page', 'Compliance sayfası'),
('ui.page.uikit', 'ui', 'page', 'UIKit sayfası'),
('ui.page.reference-data', 'ui', 'page', 'Reference data sayfası'),

-- ============================================================================
-- PAGES - Companies
-- ============================================================================
('ui.page.companies', 'ui', 'page', 'Şirketler sayfası'),
('ui.page.company-detail', 'ui', 'page', 'Şirket detay sayfası'),
('ui.page.company-users', 'ui', 'page', 'Company kullanıcıları sayfası'),
('ui.page.company-user-detail', 'ui', 'page', 'Company kullanıcı detay sayfası'),
('ui.page.company-billing', 'ui', 'page', 'Company billing sayfası'),

-- ============================================================================
-- PAGES - Tenants
-- ============================================================================
('ui.page.tenants', 'ui', 'page', 'Tenantlar sayfası'),
('ui.page.tenant-detail', 'ui', 'page', 'Tenant detay sayfası'),
('ui.page.tenant-users', 'ui', 'page', 'Tenant kullanıcıları sayfası'),
('ui.page.tenant-user-detail', 'ui', 'page', 'Tenant kullanıcı detay sayfası'),
('ui.page.tenant-settings', 'ui', 'page', 'Tenant ayarları sayfası'),
('ui.page.tenant-content', 'ui', 'page', 'Tenant content sayfası'),

-- ============================================================================
-- PAGES - Players
-- ============================================================================
('ui.page.players', 'ui', 'page', 'Oyuncular sayfası'),
('ui.page.player-detail', 'ui', 'page', 'Oyuncu detay sayfası'),
('ui.page.player-kyc', 'ui', 'page', 'Player KYC sayfası'),
('ui.page.player-kyc-detail', 'ui', 'page', 'Player KYC detay sayfası'),
('ui.page.player-rg', 'ui', 'page', 'Player responsible gaming sayfası'),

-- ============================================================================
-- PAGES - Games
-- ============================================================================
('ui.page.game-providers', 'ui', 'page', 'Game providers sayfası'),
('ui.page.game-provider-detail', 'ui', 'page', 'Game provider detay sayfası'),
('ui.page.games', 'ui', 'page', 'Oyunlar sayfası'),
('ui.page.game-detail', 'ui', 'page', 'Oyun detay sayfası'),
('ui.page.game-categories', 'ui', 'page', 'Game kategorileri sayfası'),
('ui.page.game-lobby', 'ui', 'page', 'Game lobby sayfası'),

-- ============================================================================
-- PAGES - Finance
-- ============================================================================
('ui.page.finance-transactions', 'ui', 'page', 'Finance transactions sayfası'),
('ui.page.finance-deposits', 'ui', 'page', 'Finance deposits sayfası'),
('ui.page.finance-deposit-detail', 'ui', 'page', 'Finance deposit detay sayfası'),
('ui.page.finance-withdrawals', 'ui', 'page', 'Finance withdrawals sayfası'),
('ui.page.finance-withdrawal-detail', 'ui', 'page', 'Finance withdrawal detay sayfası'),
('ui.page.finance-adjustments', 'ui', 'page', 'Finance adjustments sayfası'),
('ui.page.finance-payment-methods', 'ui', 'page', 'Finance payment methods sayfası'),

-- ============================================================================
-- PAGES - Bonuses
-- ============================================================================
('ui.page.bonuses', 'ui', 'page', 'Bonuslar sayfası'),
('ui.page.bonus-detail', 'ui', 'page', 'Bonus detay sayfası'),
('ui.page.bonus-campaigns', 'ui', 'page', 'Bonus campaigns sayfası'),
('ui.page.bonus-campaign-detail', 'ui', 'page', 'Bonus campaign detay sayfası'),
('ui.page.promo-codes', 'ui', 'page', 'Promo codes sayfası'),
('ui.page.bonus-templates', 'ui', 'page', 'Bonus templates sayfası'),

-- ============================================================================
-- PAGES - Affiliate
-- ============================================================================
('ui.page.affiliates', 'ui', 'page', 'Affiliates sayfası'),
('ui.page.affiliate-detail', 'ui', 'page', 'Affiliate detay sayfası'),
('ui.page.affiliate-commissions', 'ui', 'page', 'Affiliate commissions sayfası'),
('ui.page.affiliate-reports', 'ui', 'page', 'Affiliate reports sayfası'),

-- ============================================================================
-- PAGES - Reports
-- ============================================================================
('ui.page.report-dashboard', 'ui', 'page', 'Report dashboard sayfası'),
('ui.page.report-players', 'ui', 'page', 'Report players sayfası'),
('ui.page.report-games', 'ui', 'page', 'Report games sayfası'),
('ui.page.report-financial', 'ui', 'page', 'Report financial sayfası'),
('ui.page.report-risk', 'ui', 'page', 'Report risk sayfası'),

-- ============================================================================
-- PAGES - Audit
-- ============================================================================
('ui.page.audit-logs', 'ui', 'page', 'Audit logs sayfası'),
('ui.page.audit-log-detail', 'ui', 'page', 'Audit log detay sayfası'),
('ui.page.audit-kyc', 'ui', 'page', 'Audit KYC sayfası'),
('ui.page.audit-aml', 'ui', 'page', 'Audit AML sayfası'),
('ui.page.audit-fraud', 'ui', 'page', 'Audit fraud sayfası'),

-- ============================================================================
-- CONTEXTS - Company
-- ============================================================================
('ui.context.company-info', 'ui', 'context', 'Şirket bilgileri context'),
('ui.context.company-tenants', 'ui', 'context', 'Şirket tenantları context'),
('ui.context.company-users', 'ui', 'context', 'Şirket kullanıcıları context'),
('ui.context.company-billing', 'ui', 'context', 'Şirket billing context'),

-- ============================================================================
-- CONTEXTS - Tenant
-- ============================================================================
('ui.context.tenant-info', 'ui', 'context', 'Tenant bilgileri context'),
('ui.context.tenant-users', 'ui', 'context', 'Tenant kullanıcıları context'),
('ui.context.tenant-settings', 'ui', 'context', 'Tenant ayarları context'),
('ui.context.tenant-providers', 'ui', 'context', 'Tenant providers context'),

-- ============================================================================
-- CONTEXTS - Player
-- ============================================================================
('ui.context.player-info', 'ui', 'context', 'Player bilgileri context'),
('ui.context.player-wallet', 'ui', 'context', 'Player wallet context'),
('ui.context.player-kyc', 'ui', 'context', 'Player KYC context'),
('ui.context.player-transactions', 'ui', 'context', 'Player transactions context'),
('ui.context.player-gaming', 'ui', 'context', 'Player gaming context'),
('ui.context.player-bonuses', 'ui', 'context', 'Player bonuses context'),
('ui.context.player-limits', 'ui', 'context', 'Player limits context'),
('ui.context.player-communication', 'ui', 'context', 'Player communication context'),
('ui.context.player-actions', 'ui', 'context', 'Player actions context'),

-- ============================================================================
-- CONTEXTS - Game
-- ============================================================================
('ui.context.game-info', 'ui', 'context', 'Game bilgileri context'),
('ui.context.game-stats', 'ui', 'context', 'Game stats context'),
('ui.context.game-risk', 'ui', 'context', 'Game risk context'),

-- ============================================================================
-- CONTEXTS - Finance
-- ============================================================================
('ui.context.deposit-info', 'ui', 'context', 'Deposit bilgileri context'),
('ui.context.deposit-actions', 'ui', 'context', 'Deposit actions context'),
('ui.context.withdrawal-info', 'ui', 'context', 'Withdrawal bilgileri context'),
('ui.context.withdrawal-actions', 'ui', 'context', 'Withdrawal actions context'),

-- ============================================================================
-- CONTEXTS - Bonus
-- ============================================================================
('ui.context.bonus-info', 'ui', 'context', 'Bonus bilgileri context'),
('ui.context.bonus-rules', 'ui', 'context', 'Bonus rules context'),
('ui.context.bonus-awards', 'ui', 'context', 'Bonus awards context'),

-- ============================================================================
-- CONTEXTS - Affiliate
-- ============================================================================
('ui.context.affiliate-info', 'ui', 'context', 'Affiliate bilgileri context'),
('ui.context.affiliate-players', 'ui', 'context', 'Affiliate players context'),
('ui.context.affiliate-commissions', 'ui', 'context', 'Affiliate commissions context')

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
    ('ui.menu-group.players', 'Player Management'),
    ('ui.menu-group.games', 'Game Management'),
    ('ui.menu-group.finance', 'Finance'),
    ('ui.menu-group.bonuses', 'Bonus Management'),
    ('ui.menu-group.affiliate', 'Affiliate'),
    ('ui.menu-group.reports', 'Reports'),
    ('ui.menu-group.audit', 'Audit & Compliance'),

    -- Menus - Platform
    ('ui.menu.system', 'System'),
    ('ui.menu.rbac', 'Access Control'),
    ('ui.menu.catalog', 'Catalog'),

    -- Menus - Companies
    ('ui.menu.companies', 'Companies'),
    ('ui.menu.company-users', 'Company Users'),
    ('ui.menu.company-billing', 'Billing'),

    -- Menus - Tenants
    ('ui.menu.tenants', 'Tenants'),
    ('ui.menu.tenant-users', 'Users'),
    ('ui.menu.tenant-settings', 'Settings'),
    ('ui.menu.tenant-content', 'Content'),

    -- Menus - Players
    ('ui.menu.player-list', 'Players'),
    ('ui.menu.player-kyc', 'KYC Verification'),
    ('ui.menu.player-rg', 'Responsible Gaming'),

    -- Menus - Games
    ('ui.menu.game-providers', 'Providers'),
    ('ui.menu.game-list', 'Games'),
    ('ui.menu.game-categories', 'Categories'),
    ('ui.menu.game-lobby', 'Lobby Management'),

    -- Menus - Finance
    ('ui.menu.finance-transactions', 'Transactions'),
    ('ui.menu.finance-deposits', 'Deposits'),
    ('ui.menu.finance-withdrawals', 'Withdrawals'),
    ('ui.menu.finance-adjustments', 'Adjustments'),
    ('ui.menu.finance-payment-methods', 'Payment Methods'),

    -- Menus - Bonuses
    ('ui.menu.bonus-list', 'Bonuses'),
    ('ui.menu.bonus-campaigns', 'Campaigns'),
    ('ui.menu.promo-codes', 'Promo Codes'),
    ('ui.menu.bonus-templates', 'Templates'),

    -- Menus - Affiliate
    ('ui.menu.affiliate-list', 'Affiliates'),
    ('ui.menu.affiliate-commissions', 'Commissions'),
    ('ui.menu.affiliate-reports', 'Reports'),

    -- Menus - Reports
    ('ui.menu.report-dashboard', 'Dashboard'),
    ('ui.menu.report-players', 'Player Reports'),
    ('ui.menu.report-games', 'Game Reports'),
    ('ui.menu.report-financial', 'Financial Reports'),
    ('ui.menu.report-risk', 'Risk Reports'),

    -- Menus - Audit
    ('ui.menu.audit-logs', 'Audit Logs'),
    ('ui.menu.audit-kyc', 'KYC Audit'),
    ('ui.menu.audit-aml', 'AML & Sanctions'),
    ('ui.menu.audit-fraud', 'Fraud Detection'),

    -- Submenus - System
    ('ui.submenu.health', 'Health Check'),
    ('ui.submenu.logs', 'System Logs'),
    ('ui.submenu.system-settings', 'System Settings'),

    -- Submenus - RBAC
    ('ui.submenu.menus', 'Menu Management'),
    ('ui.submenu.roles', 'Roles'),
    ('ui.submenu.permissions', 'Permissions'),

    -- Submenus - Catalog
    ('ui.submenu.providers', 'Providers'),
    ('ui.submenu.games-catalog', 'Games'),
    ('ui.submenu.payment-methods', 'Payment Methods'),
    ('ui.submenu.compliance', 'Compliance'),
    ('ui.submenu.uikit', 'UI Kit'),
    ('ui.submenu.reference-data', 'Reference Data'),

    -- Pages - Platform
    ('ui.page.health', 'Health Check'),
    ('ui.page.logs', 'System Logs'),
    ('ui.page.system-settings', 'System Settings'),
    ('ui.page.menu-management', 'Menu Management'),
    ('ui.page.roles', 'Roles'),
    ('ui.page.permissions', 'Permissions'),
    ('ui.page.providers', 'Providers'),
    ('ui.page.games-catalog', 'Games Catalog'),
    ('ui.page.payment-methods', 'Payment Methods'),
    ('ui.page.compliance', 'Compliance'),
    ('ui.page.uikit', 'UI Kit'),
    ('ui.page.reference-data', 'Reference Data'),

    -- Pages - Companies
    ('ui.page.companies', 'Companies'),
    ('ui.page.company-detail', 'Company Details'),
    ('ui.page.company-users', 'Company Users'),
    ('ui.page.company-user-detail', 'User Details'),
    ('ui.page.company-billing', 'Billing'),

    -- Pages - Tenants
    ('ui.page.tenants', 'Tenants'),
    ('ui.page.tenant-detail', 'Tenant Details'),
    ('ui.page.tenant-users', 'Users'),
    ('ui.page.tenant-user-detail', 'User Details'),
    ('ui.page.tenant-settings', 'Settings'),
    ('ui.page.tenant-content', 'Content'),

    -- Pages - Players
    ('ui.page.players', 'Players'),
    ('ui.page.player-detail', 'Player Details'),
    ('ui.page.player-kyc', 'KYC Verification'),
    ('ui.page.player-kyc-detail', 'KYC Details'),
    ('ui.page.player-rg', 'Responsible Gaming'),

    -- Pages - Games
    ('ui.page.game-providers', 'Game Providers'),
    ('ui.page.game-provider-detail', 'Provider Details'),
    ('ui.page.games', 'Games'),
    ('ui.page.game-detail', 'Game Details'),
    ('ui.page.game-categories', 'Categories'),
    ('ui.page.game-lobby', 'Lobby Management'),

    -- Pages - Finance
    ('ui.page.finance-transactions', 'Transactions'),
    ('ui.page.finance-deposits', 'Deposits'),
    ('ui.page.finance-deposit-detail', 'Deposit Details'),
    ('ui.page.finance-withdrawals', 'Withdrawals'),
    ('ui.page.finance-withdrawal-detail', 'Withdrawal Details'),
    ('ui.page.finance-adjustments', 'Adjustments'),
    ('ui.page.finance-payment-methods', 'Payment Methods'),

    -- Pages - Bonuses
    ('ui.page.bonuses', 'Bonuses'),
    ('ui.page.bonus-detail', 'Bonus Details'),
    ('ui.page.bonus-campaigns', 'Campaigns'),
    ('ui.page.bonus-campaign-detail', 'Campaign Details'),
    ('ui.page.promo-codes', 'Promo Codes'),
    ('ui.page.bonus-templates', 'Templates'),

    -- Pages - Affiliate
    ('ui.page.affiliates', 'Affiliates'),
    ('ui.page.affiliate-detail', 'Affiliate Details'),
    ('ui.page.affiliate-commissions', 'Commissions'),
    ('ui.page.affiliate-reports', 'Reports'),

    -- Pages - Reports
    ('ui.page.report-dashboard', 'Dashboard'),
    ('ui.page.report-players', 'Player Reports'),
    ('ui.page.report-games', 'Game Reports'),
    ('ui.page.report-financial', 'Financial Reports'),
    ('ui.page.report-risk', 'Risk Reports'),

    -- Pages - Audit
    ('ui.page.audit-logs', 'Audit Logs'),
    ('ui.page.audit-log-detail', 'Log Details'),
    ('ui.page.audit-kyc', 'KYC Audit'),
    ('ui.page.audit-aml', 'AML & Sanctions'),
    ('ui.page.audit-fraud', 'Fraud Detection'),

    -- Contexts - Company
    ('ui.context.company-info', 'Company Info'),
    ('ui.context.company-tenants', 'Tenants'),
    ('ui.context.company-users', 'Users'),
    ('ui.context.company-billing', 'Billing'),

    -- Contexts - Tenant
    ('ui.context.tenant-info', 'Tenant Info'),
    ('ui.context.tenant-users', 'Users'),
    ('ui.context.tenant-settings', 'Settings'),
    ('ui.context.tenant-providers', 'Providers'),

    -- Contexts - Player
    ('ui.context.player-info', 'Player Info'),
    ('ui.context.player-wallet', 'Wallet'),
    ('ui.context.player-kyc', 'KYC'),
    ('ui.context.player-transactions', 'Transactions'),
    ('ui.context.player-gaming', 'Gaming History'),
    ('ui.context.player-bonuses', 'Bonuses'),
    ('ui.context.player-limits', 'Limits'),
    ('ui.context.player-communication', 'Communication'),
    ('ui.context.player-actions', 'Actions'),

    -- Contexts - Game
    ('ui.context.game-info', 'Game Info'),
    ('ui.context.game-stats', 'Statistics'),
    ('ui.context.game-risk', 'Risk Settings'),

    -- Contexts - Finance
    ('ui.context.deposit-info', 'Deposit Info'),
    ('ui.context.deposit-actions', 'Actions'),
    ('ui.context.withdrawal-info', 'Withdrawal Info'),
    ('ui.context.withdrawal-actions', 'Actions'),

    -- Contexts - Bonus
    ('ui.context.bonus-info', 'Bonus Info'),
    ('ui.context.bonus-rules', 'Rules'),
    ('ui.context.bonus-awards', 'Awards'),

    -- Contexts - Affiliate
    ('ui.context.affiliate-info', 'Affiliate Info'),
    ('ui.context.affiliate-players', 'Players'),
    ('ui.context.affiliate-commissions', 'Commissions')
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
    ('ui.menu-group.companies', 'Sirket Yonetimi'),
    ('ui.menu-group.tenants', 'Tenant Yonetimi'),
    ('ui.menu-group.players', 'Oyuncu Yonetimi'),
    ('ui.menu-group.games', 'Oyun Yonetimi'),
    ('ui.menu-group.finance', 'Finans'),
    ('ui.menu-group.bonuses', 'Bonus Yonetimi'),
    ('ui.menu-group.affiliate', 'Affiliate'),
    ('ui.menu-group.reports', 'Raporlar'),
    ('ui.menu-group.audit', 'Denetim ve Uyumluluk'),

    -- Menus - Platform
    ('ui.menu.system', 'Sistem'),
    ('ui.menu.rbac', 'Erisim Kontrolu'),
    ('ui.menu.catalog', 'Katalog'),

    -- Menus - Companies
    ('ui.menu.companies', 'Sirketler'),
    ('ui.menu.company-users', 'Sirket Kullanicilari'),
    ('ui.menu.company-billing', 'Faturalama'),

    -- Menus - Tenants
    ('ui.menu.tenants', 'Tenantlar'),
    ('ui.menu.tenant-users', 'Kullanicilar'),
    ('ui.menu.tenant-settings', 'Ayarlar'),
    ('ui.menu.tenant-content', 'Icerik'),

    -- Menus - Players
    ('ui.menu.player-list', 'Oyuncular'),
    ('ui.menu.player-kyc', 'KYC Dogrulama'),
    ('ui.menu.player-rg', 'Sorumlu Oyun'),

    -- Menus - Games
    ('ui.menu.game-providers', 'Saglayicilar'),
    ('ui.menu.game-list', 'Oyunlar'),
    ('ui.menu.game-categories', 'Kategoriler'),
    ('ui.menu.game-lobby', 'Lobi Yonetimi'),

    -- Menus - Finance
    ('ui.menu.finance-transactions', 'Islemler'),
    ('ui.menu.finance-deposits', 'Yatirimlar'),
    ('ui.menu.finance-withdrawals', 'Cekimler'),
    ('ui.menu.finance-adjustments', 'Duzeltmeler'),
    ('ui.menu.finance-payment-methods', 'Odeme Yontemleri'),

    -- Menus - Bonuses
    ('ui.menu.bonus-list', 'Bonuslar'),
    ('ui.menu.bonus-campaigns', 'Kampanyalar'),
    ('ui.menu.promo-codes', 'Promosyon Kodlari'),
    ('ui.menu.bonus-templates', 'Sablonlar'),

    -- Menus - Affiliate
    ('ui.menu.affiliate-list', 'Affiliatelar'),
    ('ui.menu.affiliate-commissions', 'Komisyonlar'),
    ('ui.menu.affiliate-reports', 'Raporlar'),

    -- Menus - Reports
    ('ui.menu.report-dashboard', 'Dashboard'),
    ('ui.menu.report-players', 'Oyuncu Raporlari'),
    ('ui.menu.report-games', 'Oyun Raporlari'),
    ('ui.menu.report-financial', 'Finansal Raporlar'),
    ('ui.menu.report-risk', 'Risk Raporlari'),

    -- Menus - Audit
    ('ui.menu.audit-logs', 'Denetim Kayitlari'),
    ('ui.menu.audit-kyc', 'KYC Denetimi'),
    ('ui.menu.audit-aml', 'AML ve Yaptirimlar'),
    ('ui.menu.audit-fraud', 'Dolandiricilik Tespiti'),

    -- Submenus - System
    ('ui.submenu.health', 'Saglik Kontrolu'),
    ('ui.submenu.logs', 'Sistem Loglari'),
    ('ui.submenu.system-settings', 'Sistem Ayarlari'),

    -- Submenus - RBAC
    ('ui.submenu.menus', 'Menu Yonetimi'),
    ('ui.submenu.roles', 'Roller'),
    ('ui.submenu.permissions', 'Yetkiler'),

    -- Submenus - Catalog
    ('ui.submenu.providers', 'Saglayicilar'),
    ('ui.submenu.games-catalog', 'Oyunlar'),
    ('ui.submenu.payment-methods', 'Odeme Yontemleri'),
    ('ui.submenu.compliance', 'Uyumluluk'),
    ('ui.submenu.uikit', 'UI Kit'),
    ('ui.submenu.reference-data', 'Referans Verileri'),

    -- Pages - Platform
    ('ui.page.health', 'Saglik Kontrolu'),
    ('ui.page.logs', 'Sistem Loglari'),
    ('ui.page.system-settings', 'Sistem Ayarlari'),
    ('ui.page.menu-management', 'Menu Yonetimi'),
    ('ui.page.roles', 'Roller'),
    ('ui.page.permissions', 'Yetkiler'),
    ('ui.page.providers', 'Saglayicilar'),
    ('ui.page.games-catalog', 'Oyun Katalogu'),
    ('ui.page.payment-methods', 'Odeme Yontemleri'),
    ('ui.page.compliance', 'Uyumluluk'),
    ('ui.page.uikit', 'UI Kit'),
    ('ui.page.reference-data', 'Referans Verileri'),

    -- Pages - Companies
    ('ui.page.companies', 'Sirketler'),
    ('ui.page.company-detail', 'Sirket Detayi'),
    ('ui.page.company-users', 'Sirket Kullanicilari'),
    ('ui.page.company-user-detail', 'Kullanici Detayi'),
    ('ui.page.company-billing', 'Faturalama'),

    -- Pages - Tenants
    ('ui.page.tenants', 'Tenantlar'),
    ('ui.page.tenant-detail', 'Tenant Detayi'),
    ('ui.page.tenant-users', 'Kullanicilar'),
    ('ui.page.tenant-user-detail', 'Kullanici Detayi'),
    ('ui.page.tenant-settings', 'Ayarlar'),
    ('ui.page.tenant-content', 'Icerik'),

    -- Pages - Players
    ('ui.page.players', 'Oyuncular'),
    ('ui.page.player-detail', 'Oyuncu Detayi'),
    ('ui.page.player-kyc', 'KYC Dogrulama'),
    ('ui.page.player-kyc-detail', 'KYC Detayi'),
    ('ui.page.player-rg', 'Sorumlu Oyun'),

    -- Pages - Games
    ('ui.page.game-providers', 'Oyun Saglayicilari'),
    ('ui.page.game-provider-detail', 'Saglayici Detayi'),
    ('ui.page.games', 'Oyunlar'),
    ('ui.page.game-detail', 'Oyun Detayi'),
    ('ui.page.game-categories', 'Kategoriler'),
    ('ui.page.game-lobby', 'Lobi Yonetimi'),

    -- Pages - Finance
    ('ui.page.finance-transactions', 'Islemler'),
    ('ui.page.finance-deposits', 'Yatirimlar'),
    ('ui.page.finance-deposit-detail', 'Yatirim Detayi'),
    ('ui.page.finance-withdrawals', 'Cekimler'),
    ('ui.page.finance-withdrawal-detail', 'Cekim Detayi'),
    ('ui.page.finance-adjustments', 'Duzeltmeler'),
    ('ui.page.finance-payment-methods', 'Odeme Yontemleri'),

    -- Pages - Bonuses
    ('ui.page.bonuses', 'Bonuslar'),
    ('ui.page.bonus-detail', 'Bonus Detayi'),
    ('ui.page.bonus-campaigns', 'Kampanyalar'),
    ('ui.page.bonus-campaign-detail', 'Kampanya Detayi'),
    ('ui.page.promo-codes', 'Promosyon Kodlari'),
    ('ui.page.bonus-templates', 'Sablonlar'),

    -- Pages - Affiliate
    ('ui.page.affiliates', 'Affiliatelar'),
    ('ui.page.affiliate-detail', 'Affiliate Detayi'),
    ('ui.page.affiliate-commissions', 'Komisyonlar'),
    ('ui.page.affiliate-reports', 'Raporlar'),

    -- Pages - Reports
    ('ui.page.report-dashboard', 'Dashboard'),
    ('ui.page.report-players', 'Oyuncu Raporlari'),
    ('ui.page.report-games', 'Oyun Raporlari'),
    ('ui.page.report-financial', 'Finansal Raporlar'),
    ('ui.page.report-risk', 'Risk Raporlari'),

    -- Pages - Audit
    ('ui.page.audit-logs', 'Denetim Kayitlari'),
    ('ui.page.audit-log-detail', 'Kayit Detayi'),
    ('ui.page.audit-kyc', 'KYC Denetimi'),
    ('ui.page.audit-aml', 'AML ve Yaptirimlar'),
    ('ui.page.audit-fraud', 'Dolandiricilik Tespiti'),

    -- Contexts - Company
    ('ui.context.company-info', 'Sirket Bilgileri'),
    ('ui.context.company-tenants', 'Tenantlar'),
    ('ui.context.company-users', 'Kullanicilar'),
    ('ui.context.company-billing', 'Faturalama'),

    -- Contexts - Tenant
    ('ui.context.tenant-info', 'Tenant Bilgileri'),
    ('ui.context.tenant-users', 'Kullanicilar'),
    ('ui.context.tenant-settings', 'Ayarlar'),
    ('ui.context.tenant-providers', 'Saglayicilar'),

    -- Contexts - Player
    ('ui.context.player-info', 'Oyuncu Bilgileri'),
    ('ui.context.player-wallet', 'Cuzdan'),
    ('ui.context.player-kyc', 'KYC'),
    ('ui.context.player-transactions', 'Islemler'),
    ('ui.context.player-gaming', 'Oyun Gecmisi'),
    ('ui.context.player-bonuses', 'Bonuslar'),
    ('ui.context.player-limits', 'Limitler'),
    ('ui.context.player-communication', 'Iletisim'),
    ('ui.context.player-actions', 'Islemler'),

    -- Contexts - Game
    ('ui.context.game-info', 'Oyun Bilgileri'),
    ('ui.context.game-stats', 'Istatistikler'),
    ('ui.context.game-risk', 'Risk Ayarlari'),

    -- Contexts - Finance
    ('ui.context.deposit-info', 'Yatirim Bilgileri'),
    ('ui.context.deposit-actions', 'Islemler'),
    ('ui.context.withdrawal-info', 'Cekim Bilgileri'),
    ('ui.context.withdrawal-actions', 'Islemler'),

    -- Contexts - Bonus
    ('ui.context.bonus-info', 'Bonus Bilgileri'),
    ('ui.context.bonus-rules', 'Kurallar'),
    ('ui.context.bonus-awards', 'Odullendirmeler'),

    -- Contexts - Affiliate
    ('ui.context.affiliate-info', 'Affiliate Bilgileri'),
    ('ui.context.affiliate-players', 'Oyuncular'),
    ('ui.context.affiliate-commissions', 'Komisyonlar')
) AS v(key, text) ON k.localization_key = v.key
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 4. DOGRULAMA
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
-- OZET
-- ============================================================================
--
-- Menu Groups (10):
--   platform, companies, tenants, players, games,
--   finance, bonuses, affiliate, reports, audit
--
-- Menus (31):
--   Platform: system, rbac, catalog
--   Companies: companies, company-users, company-billing
--   Tenants: tenants, tenant-users, tenant-settings, tenant-content
--   Players: player-list, player-kyc, player-rg
--   Games: game-providers, game-list, game-categories, game-lobby
--   Finance: finance-transactions, deposits, withdrawals, adjustments, payment-methods
--   Bonuses: bonus-list, bonus-campaigns, promo-codes, bonus-templates
--   Affiliate: affiliate-list, affiliate-commissions, affiliate-reports
--   Reports: dashboard, players, games, financial, risk
--   Audit: audit-logs, audit-kyc, audit-aml, audit-fraud
--
-- Submenus (12):
--   System: health, logs, system-settings
--   RBAC: menus, roles, permissions
--   Catalog: providers, games-catalog, payment-methods, compliance, uikit, reference-data
--
-- Pages (57): List + Detail pages for each menu
--
-- Contexts (32): Section/action contexts for detail pages
--
-- ============================================================================
