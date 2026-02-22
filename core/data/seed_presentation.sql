-- ================================================================
-- NUCLEO PLATFORM - PRESENTATION SEED (Menu Yapisi)
-- ================================================================
-- Sifirdan olusturulmus menu yapisi. Kaynak: Controller'lar.
-- Context kurali: Sadece permission gate (farkli permission gerektiginde).
-- ================================================================
-- CALISTIRMA SIRASI:
--   1. staging_seed_menu_localization.sql  (localization key'ler)
--   2. seed_menu_localization_content.sql  (content + security key'leri)
--   3. stating_seed.sql                    (test verileri)
--   4. permissions_full.sql                (permissions - UPSERT)
--   5. role_permissions_full.sql           (role mapping - UPSERT)
--   6. seed_presentation.sql              (bu dosya — permissions'a depend)
-- ================================================================
-- UYARI: Bu dosya TUM presentation verilerini siler ve yeniden olusturur!
-- SADECE staging/dev ortamlarinda kullanin.
-- ================================================================

-- ================================================================
-- 1. TRUNCATE (FK sirasina gore)
-- ================================================================

TRUNCATE TABLE presentation.contexts RESTART IDENTITY CASCADE;
TRUNCATE TABLE presentation.tabs RESTART IDENTITY CASCADE;
TRUNCATE TABLE presentation.pages RESTART IDENTITY CASCADE;
TRUNCATE TABLE presentation.submenus RESTART IDENTITY CASCADE;
TRUNCATE TABLE presentation.menus RESTART IDENTITY CASCADE;
TRUNCATE TABLE presentation.menu_groups RESTART IDENTITY CASCADE;

-- ================================================================
-- 2. MENU GROUPS (5)
-- ================================================================

INSERT INTO presentation.menu_groups (code, title_localization_key, order_index, is_active) VALUES
('platform',        'ui.menu-group.platform',        1, TRUE),
('companies',       'ui.menu-group.companies',        2, TRUE),
('tenants',         'ui.menu-group.tenants',          3, TRUE),
('site-management', 'ui.menu-group.site-management',  4, TRUE),
('audit',           'ui.menu-group.audit',            5, TRUE);

-- ================================================================
-- 3. MENUS (13)
-- ================================================================

-- Platform Group (3 menu)
INSERT INTO presentation.menus (menu_group_id, code, title_localization_key, icon, order_index, required_permission, is_active)
SELECT mg.id, v.code, v.title_key, v.icon, v.ord, v.perm, TRUE
FROM presentation.menu_groups mg
CROSS JOIN (VALUES
    ('system',  'ui.menu.system',  'settings',  1, 'platform.health.view'),
    ('rbac',    'ui.menu.rbac',    'shield',    2, 'platform.role.manage'),
    ('catalog', 'ui.menu.catalog', 'database',  3, 'catalog.provider.list')
) AS v(code, title_key, icon, ord, perm)
WHERE mg.code = 'platform';

-- Companies Group (1 menu)
INSERT INTO presentation.menus (menu_group_id, code, title_localization_key, icon, order_index, required_permission, is_active)
SELECT mg.id, v.code, v.title_key, v.icon, v.ord, v.perm, TRUE
FROM presentation.menu_groups mg
CROSS JOIN (VALUES
    ('companies', 'ui.menu.companies', 'building-2', 1, 'company.list')
) AS v(code, title_key, icon, ord, perm)
WHERE mg.code = 'companies';

-- Tenants Group (4 menu: 2 mevcut + 2 call center)
INSERT INTO presentation.menus (menu_group_id, code, title_localization_key, icon, order_index, required_permission, is_active)
SELECT mg.id, v.code, v.title_key, v.icon, v.ord, v.perm, TRUE
FROM presentation.menu_groups mg
CROSS JOIN (VALUES
    ('tenants',           'ui.menu.tenants',           'network',     1, 'tenant.list'),
    ('users',             'ui.menu.users',             'users',       2, 'tenant.user.list'),
    ('support-standard',  'ui.menu.support-standard',  'headphones',  3, 'tenant.support-ticket.list'),
    ('support-tickets',   'ui.menu.support-tickets',   'ticket',      4, 'tenant.support-ticket.list')
) AS v(code, title_key, icon, ord, perm)
WHERE mg.code = 'tenants';

-- Site Management Group (4 menu)
INSERT INTO presentation.menus (menu_group_id, code, title_localization_key, icon, order_index, required_permission, is_active)
SELECT mg.id, v.code, v.title_key, v.icon, v.ord, v.perm, TRUE
FROM presentation.menu_groups mg
CROSS JOIN (VALUES
    ('site-identity',   'ui.menu.site-identity',   'home',         1, 'tenant.site-settings.manage'),
    ('site-content',    'ui.menu.site-content',    'file-pen',     2, 'tenant.content.manage'),
    ('site-promotions', 'ui.menu.site-promotions', 'tag',          3, 'tenant.presentation.manage'),
    ('site-lobby',      'ui.menu.site-lobby',      'layout-grid',  4, 'tenant.content.manage')
) AS v(code, title_key, icon, ord, perm)
WHERE mg.code = 'site-management';

-- Audit Group (1 menu)
INSERT INTO presentation.menus (menu_group_id, code, title_localization_key, icon, order_index, required_permission, is_active)
SELECT mg.id, v.code, v.title_key, v.icon, v.ord, v.perm, TRUE
FROM presentation.menu_groups mg
CROSS JOIN (VALUES
    ('audit-logs', 'ui.menu.audit-logs', 'list', 1, 'audit.list')
) AS v(code, title_key, icon, ord, perm)
WHERE mg.code = 'audit';

-- ================================================================
-- 4. SUBMENUS (42)
-- ================================================================

-- System Menu (5 submenu)
INSERT INTO presentation.submenus (menu_id, code, title_localization_key, route, order_index, required_permission, is_active)
SELECT m.id, v.code, v.title_key, v.route, v.ord, v.perm, TRUE
FROM presentation.menus m
CROSS JOIN (VALUES
    ('monitoring',                'ui.submenu.monitoring',                '/system/monitoring',                1, 'platform.health.view'),
    ('error-logs',                'ui.submenu.error-logs',                '/system/error-logs',                2, 'platform.health.view'),
    ('dead-letters',              'ui.submenu.dead-letters',              '/system/dead-letters',              3, 'platform.health.view'),
    ('localization-management',   'ui.submenu.localization-management',   '/system/localization-management',   4, 'platform.localization.manage'),
    ('language-management',       'ui.submenu.language-management',       '/system/language-management',       5, 'platform.language.manage')
) AS v(code, title_key, route, ord, perm)
WHERE m.code = 'system';

-- RBAC Menu (4 submenu)
INSERT INTO presentation.submenus (menu_id, code, title_localization_key, route, order_index, required_permission, is_active)
SELECT m.id, v.code, v.title_key, v.route, v.ord, v.perm, TRUE
FROM presentation.menus m
CROSS JOIN (VALUES
    ('roles',                  'ui.submenu.roles',                  '/rbac/role-management',                  1, 'platform.role.manage'),
    ('permissions',            'ui.submenu.permissions',            '/rbac/permissions-management',            2, 'platform.permission.manage'),
    ('menus',                  'ui.submenu.menus',                  '/rbac/menu-management',        3, 'platform.presentation.manage'),
    ('permission-templates',   'ui.submenu.permission-templates',   '/rbac/permission-templates',   4, 'platform.permission-template.manage')
) AS v(code, title_key, route, ord, perm)
WHERE m.code = 'rbac';

-- Catalog Menu (14 submenu)
INSERT INTO presentation.submenus (menu_id, code, title_localization_key, route, order_index, required_permission, is_active)
SELECT m.id, v.code, v.title_key, v.route, v.ord, v.perm, TRUE
FROM presentation.menus m
CROSS JOIN (VALUES
    -- Provider
    ('providers',              'ui.submenu.providers',              '/catalog/providers',                       1,  'catalog.provider.list'),
    ('provider-types',         'ui.submenu.provider-types',         '/catalog/provider-types',                  2,  'catalog.provider.list'),
    -- Finance
    ('currencies',             'ui.submenu.currencies',             '/catalog/currencies',                      3,  'catalog.currency.list'),
    ('cryptocurrencies',       'ui.submenu.cryptocurrencies',       '/catalog/cryptocurrencies',                4,  'catalog.currency.list'),
    ('payment-methods',        'ui.submenu.payment-methods',        '/catalog/payment-methods',                 5,  'catalog.payment.list'),
    -- Compliance
    ('jurisdictions',          'ui.submenu.jurisdictions',          '/catalog/compliance/jurisdictions',         6,  'catalog.compliance.list'),
    ('kyc-policies',           'ui.submenu.kyc-policies',           '/catalog/compliance/kyc-policies',          7,  'catalog.compliance.list'),
    ('kyc-doc-requirements',   'ui.submenu.kyc-doc-requirements',   '/catalog/compliance/kyc-doc-requirements',  8,  'catalog.compliance.list'),
    ('kyc-level-requirements', 'ui.submenu.kyc-level-requirements', '/catalog/compliance/kyc-level-requirements', 9, 'catalog.compliance.list'),
    ('rg-policies',            'ui.submenu.rg-policies',            '/catalog/compliance/rg-policies',          10, 'catalog.compliance.list'),
    -- UI Kit
    ('themes',                 'ui.submenu.themes',                 '/catalog/uikit/themes',                    11, 'catalog.uikit.list'),
    ('nav-templates',          'ui.submenu.nav-templates',          '/catalog/uikit/nav-templates',             12, 'catalog.uikit.list'),
    ('widgets',                'ui.submenu.widgets',                '/catalog/uikit/widgets',                   13, 'catalog.uikit.list'),
    ('ui-positions',           'ui.submenu.ui-positions',           '/catalog/uikit/ui-positions',              14, 'catalog.uikit.list')
) AS v(code, title_key, route, ord, perm)
WHERE m.code = 'catalog';

-- Companies Menu (1 submenu)
INSERT INTO presentation.submenus (menu_id, code, title_localization_key, route, order_index, required_permission, is_active)
SELECT m.id, v.code, v.title_key, v.route, v.ord, v.perm, TRUE
FROM presentation.menus m
CROSS JOIN (VALUES
    ('company-list', 'ui.submenu.company-list', '/companies', 1, 'company.list')
) AS v(code, title_key, route, ord, perm)
WHERE m.code = 'companies';

-- Site Identity Menu (2 submenu)
INSERT INTO presentation.submenus (menu_id, code, title_localization_key, route, order_index, required_permission, is_active)
SELECT m.id, v.code, v.title_key, v.route, v.ord, v.perm, TRUE
FROM presentation.menus m
CROSS JOIN (VALUES
    ('site-settings', 'ui.submenu.site-settings', '/site/settings',     1, 'tenant.site-settings.manage'),
    ('social-links',  'ui.submenu.social-links',  '/site/social-links', 2, 'tenant.site-settings.manage')
) AS v(code, title_key, route, ord, perm)
WHERE m.code = 'site-identity';

-- Site Content Menu (5 submenu)
INSERT INTO presentation.submenus (menu_id, code, title_localization_key, route, order_index, required_permission, is_active)
SELECT m.id, v.code, v.title_key, v.route, v.ord, v.perm, TRUE
FROM presentation.menus m
CROSS JOIN (VALUES
    ('content-pages',     'ui.submenu.content-pages',     '/site/content/pages',         1, 'tenant.content.manage'),
    ('faq',               'ui.submenu.faq',               '/site/content/faq',           2, 'tenant.content.manage'),
    ('announcement-bars', 'ui.submenu.announcement-bars', '/site/content/announcements', 3, 'tenant.content.manage'),
    ('trust-logos',       'ui.submenu.trust-logos',       '/site/content/trust-logos',   4, 'tenant.content.manage'),
    ('seo',               'ui.submenu.seo',               '/site/seo',                   5, 'tenant.content.manage')
) AS v(code, title_key, route, ord, perm)
WHERE m.code = 'site-content';

-- Site Promotions Menu (3 submenu)
INSERT INTO presentation.submenus (menu_id, code, title_localization_key, route, order_index, required_permission, is_active)
SELECT m.id, v.code, v.title_key, v.route, v.ord, v.perm, TRUE
FROM presentation.menus m
CROSS JOIN (VALUES
    ('promotions', 'ui.submenu.promotions', '/site/promotions', 1, 'tenant.presentation.manage'),
    ('slides',     'ui.submenu.slides',     '/site/slides',     2, 'tenant.presentation.manage'),
    ('popups',     'ui.submenu.popups',     '/site/popups',     3, 'tenant.presentation.manage')
) AS v(code, title_key, route, ord, perm)
WHERE m.code = 'site-promotions';

-- Site Lobby Menu (2 submenu)
INSERT INTO presentation.submenus (menu_id, code, title_localization_key, route, order_index, required_permission, is_active)
SELECT m.id, v.code, v.title_key, v.route, v.ord, v.perm, TRUE
FROM presentation.menus m
CROSS JOIN (VALUES
    ('lobby-sections', 'ui.submenu.lobby-sections', '/site/lobby/sections', 1, 'tenant.content.manage'),
    ('game-labels',    'ui.submenu.game-labels',    '/site/lobby/labels',   2, 'tenant.content.manage')
) AS v(code, title_key, route, ord, perm)
WHERE m.code = 'site-lobby';

-- Support Standard Menu (3 submenu)
INSERT INTO presentation.submenus (menu_id, code, title_localization_key, route, order_index, required_permission, is_active)
SELECT m.id, v.code, v.title_key, v.route, v.ord, v.perm, TRUE
FROM presentation.menus m
CROSS JOIN (VALUES
    ('representatives', 'ui.submenu.representatives', '/support/representatives', 1, 'tenant.support-representative.view'),
    ('welcome-calls',   'ui.submenu.welcome-calls',   '/support/welcome-calls',   2, 'tenant.support-welcome-call.manage'),
    ('player-notes',    'ui.submenu.player-notes',    '/support/player-notes',    3, 'tenant.support-player-note.list')
) AS v(code, title_key, route, ord, perm)
WHERE m.code = 'support-standard';

-- Support Tickets Menu (3 submenu)
INSERT INTO presentation.submenus (menu_id, code, title_localization_key, route, order_index, required_permission, is_active)
SELECT m.id, v.code, v.title_key, v.route, v.ord, v.perm, TRUE
FROM presentation.menus m
CROSS JOIN (VALUES
    ('ticket-queue',  'ui.submenu.ticket-queue',  '/support/ticket-queue',  1, 'tenant.support-ticket.list'),
    ('ticket-config', 'ui.submenu.ticket-config', '/support/ticket-config', 2, 'tenant.support-category.manage'),
    ('agent-settings','ui.submenu.agent-settings','/support/agent-settings',3, 'tenant.support-agent.manage')
) AS v(code, title_key, route, ord, perm)
WHERE m.code = 'support-tickets';

-- ================================================================
-- 5. PAGES (54)
-- ================================================================

-- ----------------------------------------------------------------
-- 5.1 STANDALONE PAGES (menu_id=NULL, submenu_id=NULL)
-- ----------------------------------------------------------------

-- Dashboard
INSERT INTO presentation.pages (menu_id, submenu_id, code, route, title_localization_key, required_permission, order_index, is_active) VALUES
(NULL, NULL, 'page-dashboard', '/dashboard', 'ui.page.dashboard', 'platform.health.view', 0, TRUE);

-- Detail pages (7)
INSERT INTO presentation.pages (menu_id, submenu_id, code, route, title_localization_key, required_permission, order_index, is_active) VALUES
(NULL, NULL, 'page-company-detail',            '/companies/:id',                     'ui.page.company-detail',            'company.view',                        0, TRUE),
(NULL, NULL, 'page-tenant-detail',             '/tenants/:id',                       'ui.page.tenant-detail',             'tenant.view',                         0, TRUE),
(NULL, NULL, 'page-user-detail',               '/tenant-users/:id',                  'ui.page.user-detail',               'tenant.user.view',                    0, TRUE),
(NULL, NULL, 'page-role-detail',               '/rbac/roles/:id',                    'ui.page.role-detail',               'platform.role.manage',                0, TRUE),
(NULL, NULL, 'page-provider-detail',           '/catalog/providers/:id',             'ui.page.provider-detail',           'catalog.provider.view',               0, TRUE),
(NULL, NULL, 'page-nav-template-detail',       '/catalog/uikit/nav-templates/:id',   'ui.page.nav-template-detail',       'catalog.uikit.list',                  0, TRUE),
(NULL, NULL, 'page-permission-template-detail','/rbac/permission-templates/:id',     'ui.page.permission-template-detail','platform.permission-template.manage', 0, TRUE);

-- ----------------------------------------------------------------
-- 5.2 SYSTEM PAGES (5) — her submenu 1 page
-- ----------------------------------------------------------------

INSERT INTO presentation.pages (menu_id, submenu_id, code, route, title_localization_key, required_permission, order_index, is_active)
SELECT NULL, s.id, v.code, NULL, v.title_key, v.perm, v.ord, TRUE
FROM presentation.submenus s
JOIN (VALUES
    ('monitoring',              'page-monitoring',        'ui.page.monitoring',        'platform.health.view',        1),
    ('error-logs',              'page-error-logs',        'ui.page.error-logs',        'platform.health.view',        1),
    ('dead-letters',            'page-dead-letters',      'ui.page.dead-letters',      'platform.health.view',        1),
    ('localization-management', 'page-localization-keys', 'ui.page.localization-keys', 'platform.localization.manage', 1),
    ('language-management',     'page-languages',         'ui.page.languages',         'platform.language.manage',     1)
) AS v(submenu_code, code, title_key, perm, ord) ON s.code = v.submenu_code;

-- ----------------------------------------------------------------
-- 5.3 RBAC PAGES (4)
-- ----------------------------------------------------------------

INSERT INTO presentation.pages (menu_id, submenu_id, code, route, title_localization_key, required_permission, order_index, is_active)
SELECT NULL, s.id, v.code, NULL, v.title_key, v.perm, v.ord, TRUE
FROM presentation.submenus s
JOIN (VALUES
    ('roles',               'page-role-list',               'ui.page.roles',               'platform.role.manage',                1),
    ('permissions',         'page-permission-list',         'ui.page.permissions',         'platform.permission.manage',           1),
    ('menus',               'page-menu-management',         'ui.page.menu-management',     'platform.presentation.manage',         1),
    ('permission-templates','page-permission-template-list','ui.page.permission-templates','platform.permission-template.manage',  1)
) AS v(submenu_code, code, title_key, perm, ord) ON s.code = v.submenu_code;

-- ----------------------------------------------------------------
-- 5.4 CATALOG PAGES (14) — her submenu 1 page, route NULL
-- ----------------------------------------------------------------

INSERT INTO presentation.pages (menu_id, submenu_id, code, route, title_localization_key, required_permission, order_index, is_active)
SELECT NULL, s.id, v.code, NULL, v.title_key, v.perm, v.ord, TRUE
FROM presentation.submenus s
JOIN (VALUES
    -- Provider
    ('providers',              'page-provider-list',          'ui.page.providers',              'catalog.provider.list',    1),
    ('provider-types',         'page-provider-type-list',     'ui.page.provider-types',         'catalog.provider.list',    1),
    -- Finance
    ('currencies',             'page-currency-list',          'ui.page.currencies',             'catalog.currency.list',    1),
    ('cryptocurrencies',       'page-cryptocurrency-list',    'ui.page.cryptocurrencies',       'catalog.currency.list',    1),
    ('payment-methods',        'page-payment-methods',        'ui.page.payment-methods',        'catalog.payment.list',     1),
    -- Compliance
    ('jurisdictions',          'page-jurisdictions',          'ui.page.jurisdictions',          'catalog.compliance.list',  1),
    ('kyc-policies',           'page-kyc-policies',           'ui.page.kyc-policies',           'catalog.compliance.list',  1),
    ('kyc-doc-requirements',   'page-kyc-doc-requirements',   'ui.page.kyc-doc-requirements',   'catalog.compliance.list',  1),
    ('kyc-level-requirements', 'page-kyc-level-requirements', 'ui.page.kyc-level-requirements', 'catalog.compliance.list',  1),
    ('rg-policies',            'page-rg-policies',            'ui.page.rg-policies',            'catalog.compliance.list',  1),
    -- UI Kit
    ('themes',                 'page-themes',                 'ui.page.themes',                 'catalog.uikit.list',       1),
    ('nav-templates',          'page-nav-templates',          'ui.page.nav-templates',          'catalog.uikit.list',       1),
    ('widgets',                'page-widgets',                'ui.page.widgets',                'catalog.uikit.list',       1),
    ('ui-positions',           'page-ui-positions',           'ui.page.ui-positions',           'catalog.uikit.list',       1)
) AS v(submenu_code, code, title_key, perm, ord) ON s.code = v.submenu_code;

-- ----------------------------------------------------------------
-- 5.5 COMPANIES PAGES (1) — submenu'lü yapı
-- ----------------------------------------------------------------

INSERT INTO presentation.pages (menu_id, submenu_id, code, route, title_localization_key, required_permission, order_index, is_active)
SELECT NULL, s.id, v.code, NULL, v.title_key, v.perm, v.ord, TRUE
FROM presentation.submenus s
JOIN (VALUES
    ('company-list', 'page-company-list', 'ui.page.companies', 'company.list', 1)
) AS v(submenu_code, code, title_key, perm, ord) ON s.code = v.submenu_code;

-- ----------------------------------------------------------------
-- 5.6 TENANTS PAGES (2)
-- ----------------------------------------------------------------

INSERT INTO presentation.pages (menu_id, submenu_id, code, route, title_localization_key, required_permission, order_index, is_active)
SELECT m.id, NULL, v.code, v.route, v.title_key, v.perm, v.ord, TRUE
FROM presentation.menus m
JOIN (VALUES
    ('tenants', 'page-tenant-list', '/tenants',       'ui.page.tenants', 'tenant.list',      1),
    ('users',   'page-user-list',   '/tenant-users',  'ui.page.users',   'tenant.user.list', 1)
) AS v(menu_code, code, route, title_key, perm, ord) ON m.code = v.menu_code;

-- ----------------------------------------------------------------
-- 5.7 AUDIT PAGE (1)
-- ----------------------------------------------------------------

INSERT INTO presentation.pages (menu_id, submenu_id, code, route, title_localization_key, required_permission, order_index, is_active)
SELECT m.id, NULL, v.code, v.route, v.title_key, v.perm, v.ord, TRUE
FROM presentation.menus m
JOIN (VALUES
    ('audit-logs', 'page-audit-logs', '/audit-logs', 'ui.page.audit-logs', 'audit.list', 1)
) AS v(menu_code, code, route, title_key, perm, ord) ON m.code = v.menu_code;

-- ----------------------------------------------------------------
-- 5.8 SITE MANAGEMENT PAGES (12)
-- ----------------------------------------------------------------

-- Site Identity submenu pages (2)
INSERT INTO presentation.pages (menu_id, submenu_id, code, route, title_localization_key, required_permission, order_index, is_active)
SELECT NULL, s.id, v.code, NULL, v.title_key, v.perm, v.ord, TRUE
FROM presentation.submenus s
JOIN (VALUES
    ('site-settings', 'page-site-settings', 'ui.page.site-settings', 'tenant.site-settings.manage', 1),
    ('social-links',  'page-social-links',  'ui.page.social-links',  'tenant.site-settings.manage', 1)
) AS v(submenu_code, code, title_key, perm, ord) ON s.code = v.submenu_code;

-- Site Content submenu pages (5)
INSERT INTO presentation.pages (menu_id, submenu_id, code, route, title_localization_key, required_permission, order_index, is_active)
SELECT NULL, s.id, v.code, NULL, v.title_key, v.perm, v.ord, TRUE
FROM presentation.submenus s
JOIN (VALUES
    ('content-pages',     'page-content-list',      'ui.page.content-list',      'tenant.content.manage', 1),
    ('faq',               'page-faq-list',          'ui.page.faq-list',          'tenant.content.manage', 1),
    ('announcement-bars', 'page-announcement-bars', 'ui.page.announcement-bars', 'tenant.content.manage', 1),
    ('trust-logos',       'page-trust-logos',       'ui.page.trust-logos',       'tenant.content.manage', 1),
    ('seo',               'page-seo-redirects',     'ui.page.seo-redirects',     'tenant.content.manage', 1)
) AS v(submenu_code, code, title_key, perm, ord) ON s.code = v.submenu_code;

-- Site Promotions submenu pages (3)
INSERT INTO presentation.pages (menu_id, submenu_id, code, route, title_localization_key, required_permission, order_index, is_active)
SELECT NULL, s.id, v.code, NULL, v.title_key, v.perm, v.ord, TRUE
FROM presentation.submenus s
JOIN (VALUES
    ('promotions', 'page-promotions', 'ui.page.promotions', 'tenant.presentation.manage', 1),
    ('slides',     'page-slides',     'ui.page.slides',     'tenant.presentation.manage', 1),
    ('popups',     'page-popups',     'ui.page.popups',     'tenant.presentation.manage', 1)
) AS v(submenu_code, code, title_key, perm, ord) ON s.code = v.submenu_code;

-- Site Lobby submenu pages (2)
INSERT INTO presentation.pages (menu_id, submenu_id, code, route, title_localization_key, required_permission, order_index, is_active)
SELECT NULL, s.id, v.code, NULL, v.title_key, v.perm, v.ord, TRUE
FROM presentation.submenus s
JOIN (VALUES
    ('lobby-sections', 'page-lobby-sections', 'ui.page.lobby-sections', 'tenant.content.manage', 1),
    ('game-labels',    'page-game-labels',    'ui.page.game-labels',    'tenant.content.manage', 1)
) AS v(submenu_code, code, title_key, perm, ord) ON s.code = v.submenu_code;

-- ----------------------------------------------------------------
-- 5.9 CALL CENTER PAGES (6)
-- ----------------------------------------------------------------

-- Support Standard submenu pages (3)
INSERT INTO presentation.pages (menu_id, submenu_id, code, route, title_localization_key, required_permission, order_index, is_active)
SELECT NULL, s.id, v.code, NULL, v.title_key, v.perm, v.ord, TRUE
FROM presentation.submenus s
JOIN (VALUES
    ('representatives', 'page-representative-list', 'ui.page.representative-list', 'tenant.support-representative.view',  1),
    ('welcome-calls',   'page-welcome-call-list',   'ui.page.welcome-call-list',   'tenant.support-welcome-call.manage',  1),
    ('player-notes',    'page-player-note-list',    'ui.page.player-note-list',    'tenant.support-player-note.list',     1)
) AS v(submenu_code, code, title_key, perm, ord) ON s.code = v.submenu_code;

-- Support Tickets submenu pages (3)
INSERT INTO presentation.pages (menu_id, submenu_id, code, route, title_localization_key, required_permission, order_index, is_active)
SELECT NULL, s.id, v.code, NULL, v.title_key, v.perm, v.ord, TRUE
FROM presentation.submenus s
JOIN (VALUES
    ('ticket-queue',  'page-ticket-queue',  'ui.page.ticket-queue',  'tenant.support-ticket.list',    1),
    ('ticket-config', 'page-ticket-config', 'ui.page.ticket-config', 'tenant.support-category.manage',1),
    ('agent-settings','page-agent-settings','ui.page.agent-settings','tenant.support-agent.manage',   1)
) AS v(submenu_code, code, title_key, perm, ord) ON s.code = v.submenu_code;

-- ================================================================
-- 6. TABS (24)
-- ================================================================

-- Company Detail (2)
INSERT INTO presentation.tabs (page_id, code, title_localization_key, order_index, required_permission, is_active)
SELECT p.id, v.code, v.title_key, v.ord, v.perm, TRUE
FROM presentation.pages p
JOIN (VALUES
    ('page-company-detail', 'tab-company-details',        'ui.tab.company-details',        1, 'company.view'),
    ('page-company-detail', 'tab-company-password-policy','ui.tab.company-password-policy', 2, 'company.password-policy.view')
) AS v(page_code, code, title_key, ord, perm) ON p.code = v.page_code;

-- Tenant Detail (5 — 4 mevcut + 1 yeni: licenses)
INSERT INTO presentation.tabs (page_id, code, title_localization_key, order_index, required_permission, is_active)
SELECT p.id, v.code, v.title_key, v.ord, v.perm, TRUE
FROM presentation.pages p
JOIN (VALUES
    ('page-tenant-detail', 'tab-tenant-details',      'ui.tab.tenant-details',      1, 'tenant.view'),
    ('page-tenant-detail', 'tab-tenant-settings',     'ui.tab.tenant-settings',     2, 'tenant.setting.view'),
    ('page-tenant-detail', 'tab-tenant-regional',     'ui.tab.tenant-regional',     3, 'tenant.view'),
    ('page-tenant-detail', 'tab-tenant-presentation', 'ui.tab.tenant-presentation', 4, 'tenant.presentation.manage'),
    ('page-tenant-detail', 'tab-tenant-licenses',     'ui.tab.tenant-licenses',     5, 'tenant.operator-license.view')
) AS v(page_code, code, title_key, ord, perm) ON p.code = v.page_code;

-- User Detail (4)
INSERT INTO presentation.tabs (page_id, code, title_localization_key, order_index, required_permission, is_active)
SELECT p.id, v.code, v.title_key, v.ord, v.perm, TRUE
FROM presentation.pages p
JOIN (VALUES
    ('page-user-detail', 'tab-user-details',              'ui.tab.user-details',              1, 'tenant.user.view'),
    ('page-user-detail', 'tab-user-roles',                'ui.tab.user-roles',                2, 'tenant.user-role.assign'),
    ('page-user-detail', 'tab-user-permissions',          'ui.tab.user-permissions',          3, 'tenant.user-permission.grant'),
    ('page-user-detail', 'tab-user-permission-templates', 'ui.tab.user-permission-templates', 4, 'tenant.permission-template.assign')
) AS v(page_code, code, title_key, ord, perm) ON p.code = v.page_code;

-- Role Detail (2)
INSERT INTO presentation.tabs (page_id, code, title_localization_key, order_index, required_permission, is_active)
SELECT p.id, v.code, v.title_key, v.ord, v.perm, TRUE
FROM presentation.pages p
JOIN (VALUES
    ('page-role-detail', 'tab-role-details',     'ui.tab.role-details',     1, 'platform.role.manage'),
    ('page-role-detail', 'tab-role-permissions', 'ui.tab.role-permissions', 2, 'platform.role.manage')
) AS v(page_code, code, title_key, ord, perm) ON p.code = v.page_code;

-- Provider Detail (2)
INSERT INTO presentation.tabs (page_id, code, title_localization_key, order_index, required_permission, is_active)
SELECT p.id, v.code, v.title_key, v.ord, v.perm, TRUE
FROM presentation.pages p
JOIN (VALUES
    ('page-provider-detail', 'tab-provider-details',  'ui.tab.provider-details',  1, 'catalog.provider.view'),
    ('page-provider-detail', 'tab-provider-settings', 'ui.tab.provider-settings', 2, 'catalog.provider.manage')
) AS v(page_code, code, title_key, ord, perm) ON p.code = v.page_code;

-- Nav Template Detail (2)
INSERT INTO presentation.tabs (page_id, code, title_localization_key, order_index, required_permission, is_active)
SELECT p.id, v.code, v.title_key, v.ord, v.perm, TRUE
FROM presentation.pages p
JOIN (VALUES
    ('page-nav-template-detail', 'tab-nav-template-details', 'ui.tab.nav-template-details', 1, 'catalog.uikit.list'),
    ('page-nav-template-detail', 'tab-nav-template-items',   'ui.tab.nav-template-items',   2, 'catalog.uikit.manage')
) AS v(page_code, code, title_key, ord, perm) ON p.code = v.page_code;

-- Permission Template Detail (3)
INSERT INTO presentation.tabs (page_id, code, title_localization_key, order_index, required_permission, is_active)
SELECT p.id, v.code, v.title_key, v.ord, v.perm, TRUE
FROM presentation.pages p
JOIN (VALUES
    ('page-permission-template-detail', 'tab-template-details',     'ui.tab.template-details',     1, 'platform.permission-template.manage'),
    ('page-permission-template-detail', 'tab-template-permissions', 'ui.tab.template-permissions', 2, 'platform.permission-template.manage'),
    ('page-permission-template-detail', 'tab-template-assignments', 'ui.tab.template-assignments', 3, 'tenant.permission-template.assign')
) AS v(page_code, code, title_key, ord, perm) ON p.code = v.page_code;

-- Audit Logs (2)
INSERT INTO presentation.tabs (page_id, code, title_localization_key, order_index, required_permission, is_active)
SELECT p.id, v.code, v.title_key, v.ord, v.perm, TRUE
FROM presentation.pages p
JOIN (VALUES
    ('page-audit-logs', 'tab-audit-search', 'ui.tab.audit-search', 1, 'audit.list'),
    ('page-audit-logs', 'tab-audit-detail', 'ui.tab.audit-detail', 2, 'audit.view')
) AS v(page_code, code, title_key, ord, perm) ON p.code = v.page_code;

-- Localization Keys (2)
INSERT INTO presentation.tabs (page_id, code, title_localization_key, order_index, required_permission, is_active)
SELECT p.id, v.code, v.title_key, v.ord, v.perm, TRUE
FROM presentation.pages p
JOIN (VALUES
    ('page-localization-keys', 'tab-localization-keys',   'ui.tab.localization-keys',   1, 'platform.localization.manage'),
    ('page-localization-keys', 'tab-localization-values', 'ui.tab.localization-values', 2, 'platform.localization.manage')
) AS v(page_code, code, title_key, ord, perm) ON p.code = v.page_code;

-- ================================================================
-- 7. CONTEXTS (56)
-- ================================================================
-- Kural: Context SADECE farkli permission gerektiginde olusturulur.
-- Table, search, filter, immutable field icin context YOK.
-- ================================================================

-- ----------------------------------------------------------------
-- 7.1 LIST PAGE CONTEXTS (17) — tab_id=NULL
-- ----------------------------------------------------------------

-- Company List (page perm: company.list) — artik submenu altinda
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, NULL, 'ctx-company-create', 'button', 'ui.context.company-create', 'company.create', NULL, NULL, TRUE
FROM presentation.pages p WHERE p.code = 'page-company-list';

-- Tenant List (page perm: tenant.list)
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, NULL, 'ctx-tenant-create', 'button', 'ui.context.tenant-create', 'tenant.create', NULL, NULL, TRUE
FROM presentation.pages p WHERE p.code = 'page-tenant-list';

-- User List (page perm: tenant.user.list)
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, NULL, 'ctx-user-create', 'button', 'ui.context.user-create', 'tenant.user.create', NULL, NULL, TRUE
FROM presentation.pages p WHERE p.code = 'page-user-list';

-- Provider List (page perm: catalog.provider.list)
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, NULL, 'ctx-provider-create', 'button', 'ui.context.provider-create', 'catalog.provider.create', NULL, NULL, TRUE
FROM presentation.pages p WHERE p.code = 'page-provider-list';

-- Provider Type List (page perm: catalog.provider.list)
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, NULL, 'ctx-provider-type-create', 'button', 'ui.context.provider-type-create', 'catalog.provider.manage', NULL, NULL, TRUE
FROM presentation.pages p WHERE p.code = 'page-provider-type-list';

-- Currency List (page perm: catalog.currency.list)
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, NULL, 'ctx-currency-create', 'button', 'ui.context.currency-create', 'catalog.currency.manage', NULL, NULL, TRUE
FROM presentation.pages p WHERE p.code = 'page-currency-list';

-- Cryptocurrency List (page perm: catalog.currency.list)
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, NULL, 'ctx-cryptocurrency-create', 'button', 'ui.context.cryptocurrency-create', 'catalog.currency.manage', NULL, NULL, TRUE
FROM presentation.pages p WHERE p.code = 'page-cryptocurrency-list';

-- Payment Methods (page perm: catalog.payment.list)
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, NULL, 'ctx-payment-method-create', 'button', 'ui.context.payment-method-create', 'catalog.payment.manage', NULL, NULL, TRUE
FROM presentation.pages p WHERE p.code = 'page-payment-methods';

-- Jurisdictions (page perm: catalog.compliance.list)
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, NULL, 'ctx-jurisdiction-create', 'button', 'ui.context.jurisdiction-create', 'catalog.compliance.manage', NULL, NULL, TRUE
FROM presentation.pages p WHERE p.code = 'page-jurisdictions';

-- KYC Policies (page perm: catalog.compliance.list)
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, NULL, 'ctx-kyc-policy-create', 'button', 'ui.context.kyc-policy-create', 'catalog.compliance.manage', NULL, NULL, TRUE
FROM presentation.pages p WHERE p.code = 'page-kyc-policies';

-- KYC Doc Requirements (page perm: catalog.compliance.list)
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, NULL, 'ctx-kyc-doc-req-create', 'button', 'ui.context.kyc-doc-req-create', 'catalog.compliance.manage', NULL, NULL, TRUE
FROM presentation.pages p WHERE p.code = 'page-kyc-doc-requirements';

-- KYC Level Requirements (page perm: catalog.compliance.list)
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, NULL, 'ctx-kyc-level-req-create', 'button', 'ui.context.kyc-level-req-create', 'catalog.compliance.manage', NULL, NULL, TRUE
FROM presentation.pages p WHERE p.code = 'page-kyc-level-requirements';

-- RG Policies (page perm: catalog.compliance.list)
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, NULL, 'ctx-rg-policy-create', 'button', 'ui.context.rg-policy-create', 'catalog.compliance.manage', NULL, NULL, TRUE
FROM presentation.pages p WHERE p.code = 'page-rg-policies';

-- Themes (page perm: catalog.uikit.list)
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, NULL, 'ctx-theme-create', 'button', 'ui.context.theme-create', 'catalog.uikit.manage', NULL, NULL, TRUE
FROM presentation.pages p WHERE p.code = 'page-themes';

-- Nav Templates (page perm: catalog.uikit.list)
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, NULL, 'ctx-nav-template-create', 'button', 'ui.context.nav-template-create', 'catalog.uikit.manage', NULL, NULL, TRUE
FROM presentation.pages p WHERE p.code = 'page-nav-templates';

-- Widgets (page perm: catalog.uikit.list)
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, NULL, 'ctx-widget-create', 'button', 'ui.context.widget-create', 'catalog.uikit.manage', NULL, NULL, TRUE
FROM presentation.pages p WHERE p.code = 'page-widgets';

-- UI Positions (page perm: catalog.uikit.list)
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, NULL, 'ctx-ui-position-create', 'button', 'ui.context.ui-position-create', 'catalog.uikit.manage', NULL, NULL, TRUE
FROM presentation.pages p WHERE p.code = 'page-ui-positions';

-- ----------------------------------------------------------------
-- 7.2 COMPANY DETAIL CONTEXTS (3)
-- ----------------------------------------------------------------

-- Tab: Details (2 context)
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, t.id, v.code, v.ctx_type, v.label_key, v.perm_edit, NULL, NULL, TRUE
FROM presentation.pages p
JOIN presentation.tabs t ON t.page_id = p.id AND t.code = 'tab-company-details'
CROSS JOIN (VALUES
    ('ctx-company-edit',   'button', 'ui.context.company-edit',   'company.edit'),
    ('ctx-company-delete', 'action', 'ui.context.company-delete', 'company.delete')
) AS v(code, ctx_type, label_key, perm_edit)
WHERE p.code = 'page-company-detail';

-- Tab: Password Policy (1 context)
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, t.id, 'ctx-company-pp-edit', 'button', 'ui.context.company-pp-edit', 'company.password-policy.edit', NULL, NULL, TRUE
FROM presentation.pages p
JOIN presentation.tabs t ON t.page_id = p.id AND t.code = 'tab-company-password-policy'
WHERE p.code = 'page-company-detail';

-- ----------------------------------------------------------------
-- 7.4 TENANT DETAIL CONTEXTS (6 + 1 yeni: license-add)
-- ----------------------------------------------------------------

-- Tab: Details (2 context)
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, t.id, v.code, v.ctx_type, v.label_key, v.perm_edit, NULL, NULL, TRUE
FROM presentation.pages p
JOIN presentation.tabs t ON t.page_id = p.id AND t.code = 'tab-tenant-details'
CROSS JOIN (VALUES
    ('ctx-tenant-edit',   'button', 'ui.context.tenant-edit',   'tenant.edit'),
    ('ctx-tenant-delete', 'action', 'ui.context.tenant-delete', 'tenant.delete')
) AS v(code, ctx_type, label_key, perm_edit)
WHERE p.code = 'page-tenant-detail';

-- Tab: Settings (1 context)
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, t.id, 'ctx-tenant-settings-edit', 'button', 'ui.context.tenant-settings-edit', 'tenant.setting.edit', NULL, NULL, TRUE
FROM presentation.pages p
JOIN presentation.tabs t ON t.page_id = p.id AND t.code = 'tab-tenant-settings'
WHERE p.code = 'page-tenant-detail';

-- Tab: Regional (3 context)
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, t.id, v.code, v.ctx_type, v.label_key, v.perm_edit, v.perm_readonly, NULL, TRUE
FROM presentation.pages p
JOIN presentation.tabs t ON t.page_id = p.id AND t.code = 'tab-tenant-regional'
CROSS JOIN (VALUES
    ('ctx-tenant-currencies', 'select', 'ui.context.tenant-currencies', 'tenant.currency.edit',        'tenant.currency.list'),
    ('ctx-tenant-languages',  'select', 'ui.context.tenant-languages',  'tenant.language.edit',        'tenant.language.list'),
    ('ctx-tenant-crypto',     'select', 'ui.context.tenant-crypto',     'tenant.cryptocurrency.edit',  'tenant.cryptocurrency.list')
) AS v(code, ctx_type, label_key, perm_edit, perm_readonly)
WHERE p.code = 'page-tenant-detail';

-- Tab: Presentation — 0 context (tum islemler tenant.presentation.manage)

-- Tab: Licenses (1 context — add izni farklı)
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, t.id, 'ctx-tenant-license-add', 'button', 'ui.context.tenant-license-add', 'tenant.operator-license.manage', NULL, NULL, TRUE
FROM presentation.pages p
JOIN presentation.tabs t ON t.page_id = p.id AND t.code = 'tab-tenant-licenses'
WHERE p.code = 'page-tenant-detail';

-- ----------------------------------------------------------------
-- 7.5 USER DETAIL CONTEXTS (7)
-- ----------------------------------------------------------------

-- Tab: Details — PII Fields (4 context)
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, t.id, v.code, v.ctx_type, v.label_key, v.perm_edit, v.perm_readonly, v.perm_mask, TRUE
FROM presentation.pages p
JOIN presentation.tabs t ON t.page_id = p.id AND t.code = 'tab-user-details'
CROSS JOIN (VALUES
    ('ctx-user-email',      'input', 'ui.context.user-email',      'field.user-email.edit',     'field.user-email.view',     'field.user-email.mask'),
    ('ctx-user-username',   'input', 'ui.context.user-username',   'field.user-username.edit',  'field.user-username.view',  'field.user-username.mask'),
    ('ctx-user-first-name', 'input', 'ui.context.user-first-name', 'field.user-firstname.edit', 'field.user-firstname.view', 'field.user-firstname.mask'),
    ('ctx-user-last-name',  'input', 'ui.context.user-last-name',  'field.user-lastname.edit',  'field.user-lastname.view',  'field.user-lastname.mask')
) AS v(code, ctx_type, label_key, perm_edit, perm_readonly, perm_mask)
WHERE p.code = 'page-user-detail';

-- Tab: Details — Non-PII (2 context)
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, t.id, v.code, v.ctx_type, v.label_key, v.perm_edit, NULL, NULL, TRUE
FROM presentation.pages p
JOIN presentation.tabs t ON t.page_id = p.id AND t.code = 'tab-user-details'
CROSS JOIN (VALUES
    ('ctx-user-edit',   'button', 'ui.context.user-edit',   'tenant.user.edit'),
    ('ctx-user-delete', 'action', 'ui.context.user-delete', 'tenant.user.delete')
) AS v(code, ctx_type, label_key, perm_edit)
WHERE p.code = 'page-user-detail';

-- Tab: Roles — 0 context (tek permission: tenant.user-role.assign)
-- Tab: Permission Templates — 0 context (tek permission: tenant.permission-template.assign)

-- Tab: Permissions (1 context — deny farkli permission)
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, t.id, 'ctx-user-deny-permission', 'action', 'ui.context.user-deny-permission', 'tenant.user-permission.deny', NULL, NULL, TRUE
FROM presentation.pages p
JOIN presentation.tabs t ON t.page_id = p.id AND t.code = 'tab-user-permissions'
WHERE p.code = 'page-user-detail';

-- ----------------------------------------------------------------
-- 7.6 PROVIDER DETAIL CONTEXTS (2)
-- ----------------------------------------------------------------

INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, t.id, v.code, v.ctx_type, v.label_key, v.perm_edit, NULL, NULL, TRUE
FROM presentation.pages p
JOIN presentation.tabs t ON t.page_id = p.id AND t.code = 'tab-provider-details'
CROSS JOIN (VALUES
    ('ctx-provider-edit',   'button', 'ui.context.provider-edit',   'catalog.provider.edit'),
    ('ctx-provider-delete', 'action', 'ui.context.provider-delete', 'catalog.provider.delete')
) AS v(code, ctx_type, label_key, perm_edit)
WHERE p.code = 'page-provider-detail';

-- Tab: Settings — 0 context (tek permission: catalog.provider.manage)

-- ----------------------------------------------------------------
-- 7.7 NAV TEMPLATE DETAIL CONTEXTS (1)
-- ----------------------------------------------------------------

INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, t.id, 'ctx-nav-template-edit', 'button', 'ui.context.nav-template-edit', 'catalog.uikit.manage', NULL, NULL, TRUE
FROM presentation.pages p
JOIN presentation.tabs t ON t.page_id = p.id AND t.code = 'tab-nav-template-details'
WHERE p.code = 'page-nav-template-detail';

-- Tab: Items — 0 context (tek permission: catalog.uikit.manage)

-- ----------------------------------------------------------------
-- 7.8 PERMISSION TEMPLATE DETAIL — 0 context
-- ----------------------------------------------------------------
-- Tum tab'lar tek permission: platform.permission-template.manage veya tenant.permission-template.assign

-- ----------------------------------------------------------------
-- 7.9 AUDIT CONTEXTS (1)
-- ----------------------------------------------------------------

-- Tab: Search — audit.view farkli
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, t.id, 'ctx-audit-view', 'action', 'ui.context.audit-view', NULL, 'audit.view', NULL, TRUE
FROM presentation.pages p
JOIN presentation.tabs t ON t.page_id = p.id AND t.code = 'tab-audit-search'
WHERE p.code = 'page-audit-logs';

-- Tab: Detail — 0 context (tek permission: audit.view)

-- ----------------------------------------------------------------
-- 7.10 LOCALIZATION — 0 context
-- ----------------------------------------------------------------
-- Tum tab'lar tek permission: platform.localization.manage

-- ----------------------------------------------------------------
-- 7.11 ROLE DETAIL — 0 context
-- ----------------------------------------------------------------
-- Tum tab'lar tek permission: platform.role.manage

-- ----------------------------------------------------------------
-- 7.12 SITE MANAGEMENT CONTEXTS (10)
-- ----------------------------------------------------------------

-- Trust Logos page (page perm: tenant.content.manage)
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, NULL, v.code, v.ctx_type, v.label_key, v.perm_edit, NULL, NULL, TRUE
FROM presentation.pages p
CROSS JOIN (VALUES
    ('ctx-trust-logo-create',       'button', 'ui.context.trust-logo-create',      'tenant.content.manage'),
    ('ctx-trust-logo-edit',         'button', 'ui.context.trust-logo-edit',        'tenant.content.manage')
) AS v(code, ctx_type, label_key, perm_edit)
WHERE p.code = 'page-trust-logos';

-- Social Links page (page perm: tenant.site-settings.manage)
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, NULL, v.code, v.ctx_type, v.label_key, v.perm_edit, NULL, NULL, TRUE
FROM presentation.pages p
CROSS JOIN (VALUES
    ('ctx-social-link-create', 'button', 'ui.context.social-link-create', 'tenant.site-settings.manage'),
    ('ctx-social-link-edit',   'button', 'ui.context.social-link-edit',   'tenant.site-settings.manage')
) AS v(code, ctx_type, label_key, perm_edit)
WHERE p.code = 'page-social-links';

-- Announcement Bars page (page perm: tenant.content.manage)
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, NULL, v.code, v.ctx_type, v.label_key, v.perm_edit, NULL, NULL, TRUE
FROM presentation.pages p
CROSS JOIN (VALUES
    ('ctx-announcement-bar-create', 'button', 'ui.context.announcement-bar-create', 'tenant.content.manage'),
    ('ctx-announcement-bar-edit',   'button', 'ui.context.announcement-bar-edit',   'tenant.content.manage')
) AS v(code, ctx_type, label_key, perm_edit)
WHERE p.code = 'page-announcement-bars';

-- Lobby Sections page (page perm: tenant.content.manage)
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, NULL, 'ctx-lobby-section-create', 'button', 'ui.context.lobby-section-create', 'tenant.content.manage', NULL, NULL, TRUE
FROM presentation.pages p WHERE p.code = 'page-lobby-sections';

-- Game Labels page (page perm: tenant.content.manage)
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, NULL, 'ctx-game-label-create', 'button', 'ui.context.game-label-create', 'tenant.content.manage', NULL, NULL, TRUE
FROM presentation.pages p WHERE p.code = 'page-game-labels';

-- SEO Redirects page (page perm: tenant.content.manage)
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, NULL, 'ctx-seo-redirect-create', 'button', 'ui.context.seo-redirect-create', 'tenant.content.manage', NULL, NULL, TRUE
FROM presentation.pages p WHERE p.code = 'page-seo-redirects';

-- ----------------------------------------------------------------
-- 7.13 CALL CENTER CONTEXTS (7)
-- ----------------------------------------------------------------

-- Representatives page
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, NULL, 'ctx-representative-assign', 'button', 'ui.context.representative-assign', 'tenant.support-representative.manage', NULL, NULL, TRUE
FROM presentation.pages p WHERE p.code = 'page-representative-list';

-- Welcome Calls page
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, NULL, 'ctx-welcome-call-assign', 'button', 'ui.context.welcome-call-assign', 'tenant.support-welcome-call.manage', NULL, NULL, TRUE
FROM presentation.pages p WHERE p.code = 'page-welcome-call-list';

-- Player Notes page
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, NULL, 'ctx-player-note-create', 'button', 'ui.context.player-note-create', 'tenant.support-player-note.manage', NULL, NULL, TRUE
FROM presentation.pages p WHERE p.code = 'page-player-note-list';

-- Ticket Queue page (2 context — create ve assign farklı permission gerektiriyor)
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, NULL, v.code, v.ctx_type, v.label_key, v.perm_edit, NULL, NULL, TRUE
FROM presentation.pages p
CROSS JOIN (VALUES
    ('ctx-ticket-create', 'button', 'ui.context.ticket-create', 'tenant.support-ticket.create'),
    ('ctx-ticket-assign', 'action', 'ui.context.ticket-assign', 'tenant.support-ticket.assign')
) AS v(code, ctx_type, label_key, perm_edit)
WHERE p.code = 'page-ticket-queue';

-- Ticket Config page (2 context — category-create ve canned-response-create)
INSERT INTO presentation.contexts (page_id, tab_id, code, context_type, label_localization_key, permission_edit, permission_readonly, permission_mask, is_active)
SELECT p.id, NULL, v.code, v.ctx_type, v.label_key, v.perm_edit, NULL, NULL, TRUE
FROM presentation.pages p
CROSS JOIN (VALUES
    ('ctx-ticket-category-create', 'button', 'ui.context.ticket-category-create', 'tenant.support-category.manage'),
    ('ctx-canned-response-create', 'button', 'ui.context.canned-response-create', 'tenant.support-canned-response.manage')
) AS v(code, ctx_type, label_key, perm_edit)
WHERE p.code = 'page-ticket-config';

-- ================================================================
-- 8. DOGRULAMA
-- ================================================================

DO $$
DECLARE
    v_menu_groups INT; v_menus INT; v_submenus INT;
    v_pages INT; v_tabs INT; v_contexts INT;
BEGIN
    SELECT COUNT(*) INTO v_menu_groups FROM presentation.menu_groups;
    SELECT COUNT(*) INTO v_menus FROM presentation.menus;
    SELECT COUNT(*) INTO v_submenus FROM presentation.submenus;
    SELECT COUNT(*) INTO v_pages FROM presentation.pages;
    SELECT COUNT(*) INTO v_tabs FROM presentation.tabs;
    SELECT COUNT(*) INTO v_contexts FROM presentation.contexts;

    RAISE NOTICE '================================================';
    RAISE NOTICE 'SEED PRESENTATION TAMAMLANDI';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Menu Groups: % (beklenen: 5)', v_menu_groups;
    RAISE NOTICE 'Menus: % (beklenen: 13)', v_menus;
    RAISE NOTICE 'Submenus: % (beklenen: 42)', v_submenus;
    RAISE NOTICE 'Pages: % (beklenen: 53)', v_pages;
    RAISE NOTICE 'Tabs: % (beklenen: 24)', v_tabs;
    RAISE NOTICE 'Contexts: % (beklenen: 54)', v_contexts;
    RAISE NOTICE '================================================';
END $$;
