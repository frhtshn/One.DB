-- ================================================================
-- SORTIS ONE - MENU LOCALIZATION SEED (CONTENT & SECURITY)
-- ================================================================
-- staging_seed_menu_localization.sql ile birebir uyumlu.
-- Bu dosya seed_presentation.sql'den ÖNCE çalıştırılmalıdır.
-- ================================================================
-- Kapsam:
--   FRONTEND_CONTENT_DESIGN: site-management grubu + call center menüleri (+55 key)
--   SECURITY_POLICY_DESIGN:  companies submenü (+1 key)
-- ================================================================
-- Toplam bu dosya: 72 key
-- Genel toplam (tüm seed dosyaları): 187 key
-- ================================================================

-- ================================================================
-- 1. LOCALIZATION KEYS
-- ================================================================

INSERT INTO catalog.localization_keys (localization_key, domain, category, description) VALUES

-- ----------------------------------------------------------------
-- FRONTEND_CONTENT — MENU GROUP (1)
-- ----------------------------------------------------------------
('ui.menu-group.site-management', 'ui', 'menu', 'Site Management menu grubu'),

-- ----------------------------------------------------------------
-- FRONTEND_CONTENT — MENUS (4)
-- ----------------------------------------------------------------
('ui.menu.site-identity',   'ui', 'menu', 'Site Identity menüsü'),
('ui.menu.site-content',    'ui', 'menu', 'Site Content menüsü'),
('ui.menu.site-promotions', 'ui', 'menu', 'Promotions menüsü'),
('ui.menu.site-lobby',      'ui', 'menu', 'Game Lobby menüsü'),

-- ----------------------------------------------------------------
-- FRONTEND_CONTENT — SUBMENUS (12)
-- ----------------------------------------------------------------
('ui.submenu.site-settings',     'ui', 'menu', 'Site Settings alt menüsü'),
('ui.submenu.social-links',      'ui', 'menu', 'Social Links alt menüsü'),
('ui.submenu.content-pages',     'ui', 'menu', 'Content Pages alt menüsü'),
('ui.submenu.faq',               'ui', 'menu', 'FAQ alt menüsü'),
('ui.submenu.announcement-bars', 'ui', 'menu', 'Announcement Bars alt menüsü'),
('ui.submenu.trust-logos',       'ui', 'menu', 'Trust Logos alt menüsü'),
('ui.submenu.seo',               'ui', 'menu', 'SEO alt menüsü'),
('ui.submenu.promotions', 'ui', 'menu', 'Promotions alt menüsü'),
('ui.submenu.slides',     'ui', 'menu', 'Slides alt menüsü'),
('ui.submenu.popups',          'ui', 'menu', 'Pop-ups alt menüsü'),
('ui.submenu.lobby-sections',  'ui', 'menu', 'Lobby Sections alt menüsü'),
('ui.submenu.game-labels',     'ui', 'menu', 'Game Labels alt menüsü'),

-- ----------------------------------------------------------------
-- FRONTEND_CONTENT — PAGES (12)
-- ----------------------------------------------------------------
('ui.page.site-settings',      'ui', 'page', 'Site settings sayfası'),
('ui.page.social-links',       'ui', 'page', 'Social links sayfası'),
('ui.page.content-list',       'ui', 'page', 'Content list sayfası'),
('ui.page.faq-list',           'ui', 'page', 'FAQ list sayfası'),
('ui.page.announcement-bars',  'ui', 'page', 'Announcement bars sayfası'),
('ui.page.trust-logos',        'ui', 'page', 'Trust logos sayfası'),
('ui.page.seo-redirects',      'ui', 'page', 'SEO redirects sayfası'),
('ui.page.promotions',         'ui', 'page', 'Promotions sayfası'),
('ui.page.slides',             'ui', 'page', 'Slides sayfası'),
('ui.page.popups',             'ui', 'page', 'Pop-ups sayfası'),
('ui.page.lobby-sections',     'ui', 'page', 'Lobby sections sayfası'),
('ui.page.game-labels',        'ui', 'page', 'Game labels sayfası'),

-- ----------------------------------------------------------------
-- FRONTEND_CONTENT — TABS (1)
-- ----------------------------------------------------------------
('ui.tab.client-licenses', 'ui', 'tab', 'Client licenses sekmesi'),

-- ----------------------------------------------------------------
-- FRONTEND_CONTENT — CONTEXTS (10)
-- ----------------------------------------------------------------
('ui.context.client-license-add',       'ui', 'context', 'Client license add button'),
('ui.context.social-link-create',       'ui', 'context', 'Social link create button'),
('ui.context.social-link-edit',         'ui', 'context', 'Social link edit button'),
('ui.context.announcement-bar-create',  'ui', 'context', 'Announcement bar create button'),
('ui.context.announcement-bar-edit',    'ui', 'context', 'Announcement bar edit button'),
('ui.context.trust-logo-create',        'ui', 'context', 'Trust logo create button'),
('ui.context.trust-logo-edit',          'ui', 'context', 'Trust logo edit button'),
('ui.context.lobby-section-create',     'ui', 'context', 'Lobby section create button'),
('ui.context.game-label-create',        'ui', 'context', 'Game label create button'),
('ui.context.seo-redirect-create',      'ui', 'context', 'SEO redirect create button'),

-- ----------------------------------------------------------------
-- CALL CENTER — MENUS (2)
-- ----------------------------------------------------------------
('ui.menu.support-standard', 'ui', 'menu', 'Support Standard menüsü'),
('ui.menu.support-tickets',  'ui', 'menu', 'Support Tickets menüsü (plugin gerekli)'),

-- ----------------------------------------------------------------
-- CALL CENTER — SUBMENUS (6)
-- ----------------------------------------------------------------
('ui.submenu.representatives', 'ui', 'menu', 'Representatives alt menüsü'),
('ui.submenu.welcome-calls',   'ui', 'menu', 'Welcome Calls alt menüsü'),
('ui.submenu.player-notes',    'ui', 'menu', 'Player Notes alt menüsü'),
('ui.submenu.ticket-queue',    'ui', 'menu', 'Ticket Queue alt menüsü'),
('ui.submenu.ticket-config',   'ui', 'menu', 'Ticket Config alt menüsü'),
('ui.submenu.agent-settings',  'ui', 'menu', 'Agent Settings alt menüsü'),

-- ----------------------------------------------------------------
-- CALL CENTER — PAGES (6)
-- ----------------------------------------------------------------
('ui.page.representative-list', 'ui', 'page', 'Representative list sayfası'),
('ui.page.welcome-call-list',   'ui', 'page', 'Welcome call list sayfası'),
('ui.page.player-note-list',    'ui', 'page', 'Player note list sayfası'),
('ui.page.ticket-queue',        'ui', 'page', 'Ticket queue sayfası'),
('ui.page.ticket-config',       'ui', 'page', 'Ticket config sayfası'),
('ui.page.agent-settings',      'ui', 'page', 'Agent settings sayfası'),

-- ----------------------------------------------------------------
-- CALL CENTER — CONTEXTS (7)
-- ----------------------------------------------------------------
('ui.context.representative-assign',   'ui', 'context', 'Representative assign button'),
('ui.context.welcome-call-assign',     'ui', 'context', 'Welcome call assign button'),
('ui.context.player-note-create',      'ui', 'context', 'Player note create button'),
('ui.context.ticket-create',           'ui', 'context', 'Ticket create button'),
('ui.context.ticket-assign',           'ui', 'context', 'Ticket assign button'),
('ui.context.ticket-category-create',  'ui', 'context', 'Ticket category create button'),
('ui.context.canned-response-create',  'ui', 'context', 'Canned response create button'),

-- ----------------------------------------------------------------
-- SECURITY_POLICY — SUBMENUS (1)
-- ----------------------------------------------------------------
('ui.submenu.company-list', 'ui', 'menu', 'Companies list alt menüsü')

ON CONFLICT (localization_key) DO NOTHING;

-- ================================================================
-- 2. ENGLISH VALUES
-- ================================================================

INSERT INTO catalog.localization_values (localization_key_id, language_code, localized_text, created_at)
SELECT k.id, 'en', v.text, NOW()
FROM catalog.localization_keys k
JOIN (VALUES

-- Menu Group (1)
('ui.menu-group.site-management', 'Site Management'),

-- Menus (4)
('ui.menu.site-identity',   'Site Identity'),
('ui.menu.site-content',    'Content'),
('ui.menu.site-promotions', 'Promotions'),
('ui.menu.site-lobby',      'Game Lobby'),

-- Submenus (12)
('ui.submenu.site-settings',     'Site Settings'),
('ui.submenu.social-links',      'Social Links'),
('ui.submenu.content-pages',     'Content Pages'),
('ui.submenu.faq',               'FAQ'),
('ui.submenu.announcement-bars', 'Announcement Bars'),
('ui.submenu.trust-logos',       'Trust Logos'),
('ui.submenu.seo',               'SEO'),
('ui.submenu.promotions', 'Promotions'),
('ui.submenu.slides',     'Slides'),
('ui.submenu.popups',          'Pop-ups'),
('ui.submenu.lobby-sections',  'Lobby Sections'),
('ui.submenu.game-labels',     'Game Labels'),

-- Pages (12)
('ui.page.site-settings',      'Site Settings'),
('ui.page.social-links',       'Social Links'),
('ui.page.content-list',       'Content Pages'),
('ui.page.faq-list',           'FAQ'),
('ui.page.announcement-bars',  'Announcement Bars'),
('ui.page.trust-logos',        'Trust Logos'),
('ui.page.seo-redirects',      'SEO Redirects'),
('ui.page.promotions',         'Promotions'),
('ui.page.slides',             'Slides'),
('ui.page.popups',             'Pop-ups'),
('ui.page.lobby-sections',     'Lobby Sections'),
('ui.page.game-labels',        'Game Labels'),

-- Tabs (1)
('ui.tab.client-licenses', 'Licenses'),

-- Contexts - Site Management (10)
('ui.context.client-license-add',      'Add License'),
('ui.context.social-link-create',      'Add Social Link'),
('ui.context.social-link-edit',        'Edit Social Link'),
('ui.context.announcement-bar-create', 'Create Announcement'),
('ui.context.announcement-bar-edit',   'Edit Announcement'),
('ui.context.trust-logo-create',       'Add Logo'),
('ui.context.trust-logo-edit',         'Edit Logo'),
('ui.context.lobby-section-create',    'Create Section'),
('ui.context.game-label-create',       'Create Label'),
('ui.context.seo-redirect-create',     'Add Redirect'),

-- Call Center Menus (2)
('ui.menu.support-standard', 'Support'),
('ui.menu.support-tickets',  'Ticket Management'),

-- Call Center Submenus (6)
('ui.submenu.representatives', 'Representatives'),
('ui.submenu.welcome-calls',   'Welcome Calls'),
('ui.submenu.player-notes',    'Player Notes'),
('ui.submenu.ticket-queue',    'Ticket Queue'),
('ui.submenu.ticket-config',   'Configuration'),
('ui.submenu.agent-settings',  'Agent Settings'),

-- Call Center Pages (6)
('ui.page.representative-list', 'Representatives'),
('ui.page.welcome-call-list',   'Welcome Calls'),
('ui.page.player-note-list',    'Player Notes'),
('ui.page.ticket-queue',        'Ticket Queue'),
('ui.page.ticket-config',       'Configuration'),
('ui.page.agent-settings',      'Agent Settings'),

-- Call Center Contexts (7)
('ui.context.representative-assign',   'Assign Representative'),
('ui.context.welcome-call-assign',     'Take Task'),
('ui.context.player-note-create',      'Add Note'),
('ui.context.ticket-create',           'Create Ticket'),
('ui.context.ticket-assign',           'Assign Ticket'),
('ui.context.ticket-category-create',  'Create Category'),
('ui.context.canned-response-create',  'Create Template'),

-- Security Policy - Submenus (1)
('ui.submenu.company-list', 'Companies')

) AS v(key, text) ON k.localization_key = v.key
ON CONFLICT (localization_key_id, language_code) DO NOTHING;

-- ================================================================
-- 3. TURKISH VALUES (tr)
-- ================================================================

INSERT INTO catalog.localization_values (localization_key_id, language_code, localized_text, created_at)
SELECT k.id, 'tr', v.text, NOW()
FROM catalog.localization_keys k
JOIN (VALUES

-- Menu Group (1)
('ui.menu-group.site-management', 'Site Yönetimi'),

-- Menus (4)
('ui.menu.site-identity',   'Site Kimliği'),
('ui.menu.site-content',    'İçerik'),
('ui.menu.site-promotions', 'Promosyonlar'),
('ui.menu.site-lobby',      'Oyun Lobisi'),

-- Submenus (12)
('ui.submenu.site-settings',     'Site Ayarları'),
('ui.submenu.social-links',      'Sosyal Linkler'),
('ui.submenu.content-pages',     'İçerik Sayfaları'),
('ui.submenu.faq',               'SSS'),
('ui.submenu.announcement-bars', 'Duyuru Barları'),
('ui.submenu.trust-logos',       'Güven Logoları'),
('ui.submenu.seo',               'SEO'),
('ui.submenu.promotions', 'Promosyonlar'),
('ui.submenu.slides',     'Slaytlar'),
('ui.submenu.popups',          'Pop-up''lar'),
('ui.submenu.lobby-sections',  'Lobi Bölümleri'),
('ui.submenu.game-labels',     'Oyun Etiketleri'),

-- Pages (12)
('ui.page.site-settings',      'Site Ayarları'),
('ui.page.social-links',       'Sosyal Linkler'),
('ui.page.content-list',       'İçerik Sayfaları'),
('ui.page.faq-list',           'SSS'),
('ui.page.announcement-bars',  'Duyuru Çubukları'),
('ui.page.trust-logos',        'Güven Logoları'),
('ui.page.seo-redirects',      'SEO Yönlendirmeleri'),
('ui.page.promotions',         'Promosyonlar'),
('ui.page.slides',             'Slaytlar'),
('ui.page.popups',             'Pop-up''lar'),
('ui.page.lobby-sections',     'Lobi Bölümleri'),
('ui.page.game-labels',        'Oyun Etiketleri'),

-- Tabs (1)
('ui.tab.client-licenses', 'Lisanslar'),

-- Contexts - Site Management (10)
('ui.context.client-license-add',      'Lisans Ekle'),
('ui.context.social-link-create',      'Sosyal Link Ekle'),
('ui.context.social-link-edit',        'Sosyal Linki Düzenle'),
('ui.context.announcement-bar-create', 'Duyuru Oluştur'),
('ui.context.announcement-bar-edit',   'Duyuruyu Düzenle'),
('ui.context.trust-logo-create',       'Logo Ekle'),
('ui.context.trust-logo-edit',         'Logoyu Düzenle'),
('ui.context.lobby-section-create',    'Bölüm Oluştur'),
('ui.context.game-label-create',       'Etiket Oluştur'),
('ui.context.seo-redirect-create',     'Yönlendirme Ekle'),

-- Call Center Menüler (2)
('ui.menu.support-standard', 'Destek'),
('ui.menu.support-tickets',  'Ticket Yönetimi'),

-- Call Center Alt Menüler (6)
('ui.submenu.representatives', 'Temsilciler'),
('ui.submenu.welcome-calls',   'Hoşgeldin Aramaları'),
('ui.submenu.player-notes',    'Oyuncu Notları'),
('ui.submenu.ticket-queue',    'Ticket Kuyruğu'),
('ui.submenu.ticket-config',   'Yapılandırma'),
('ui.submenu.agent-settings',  'Agent Ayarları'),

-- Call Center Sayfalar (6)
('ui.page.representative-list', 'Temsilciler'),
('ui.page.welcome-call-list',   'Hoşgeldin Aramaları'),
('ui.page.player-note-list',    'Oyuncu Notları'),
('ui.page.ticket-queue',        'Ticket Kuyruğu'),
('ui.page.ticket-config',       'Yapılandırma'),
('ui.page.agent-settings',      'Agent Ayarları'),

-- Call Center Context'ler (7)
('ui.context.representative-assign',   'Temsilci Ata'),
('ui.context.welcome-call-assign',     'Görevi Al'),
('ui.context.player-note-create',      'Not Ekle'),
('ui.context.ticket-create',           'Ticket Oluştur'),
('ui.context.ticket-assign',           'Ticket Ata'),
('ui.context.ticket-category-create',  'Kategori Oluştur'),
('ui.context.canned-response-create',  'Şablon Oluştur'),

-- Security Policy - Submenüler (1)
('ui.submenu.company-list', 'Şirketler')

) AS v(key, text) ON k.localization_key = v.key
ON CONFLICT (localization_key_id, language_code) DO NOTHING;
