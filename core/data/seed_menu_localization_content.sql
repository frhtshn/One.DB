-- ================================================================
-- NUCLEO PLATFORM - MENU LOCALIZATION SEED (CONTENT & SECURITY)
-- ================================================================
-- staging_seed_menu_localization.sql ile birebir uyumlu.
-- Bu dosya seed_presentation.sql'den ÖNCE çalıştırılmalıdır.
-- ================================================================
-- Kapsam:
--   FRONTEND_CONTENT_DESIGN: site-management grubu + call center menüleri (+55 key)
--   SECURITY_POLICY_DESIGN:  companies submenü + password-policies (+5 key)
-- ================================================================
-- Toplam bu dosya: 60 key
-- Genel toplam (tüm seed dosyaları): 175 key
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
-- FRONTEND_CONTENT — SUBMENUS (6)
-- ----------------------------------------------------------------
('ui.submenu.cms',        'ui', 'menu', 'CMS alt menüsü'),
('ui.submenu.notices',    'ui', 'menu', 'Notices & Badges alt menüsü'),
('ui.submenu.seo',        'ui', 'menu', 'SEO alt menüsü'),
('ui.submenu.promotions', 'ui', 'menu', 'Promotions alt menüsü'),
('ui.submenu.slides',     'ui', 'menu', 'Slides alt menüsü'),
('ui.submenu.popups',     'ui', 'menu', 'Pop-ups alt menüsü'),

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
('ui.tab.tenant-licenses', 'ui', 'tab', 'Tenant licenses sekmesi'),

-- ----------------------------------------------------------------
-- FRONTEND_CONTENT — CONTEXTS (10)
-- ----------------------------------------------------------------
('ui.context.tenant-license-add',       'ui', 'context', 'Tenant license add button'),
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
-- SECURITY_POLICY — SUBMENUS (2)
-- ----------------------------------------------------------------
('ui.submenu.company-list',      'ui', 'menu', 'Companies list alt menüsü'),
('ui.submenu.password-policies', 'ui', 'menu', 'Password Policies alt menüsü'),

-- ----------------------------------------------------------------
-- SECURITY_POLICY — PAGES (1)
-- ----------------------------------------------------------------
('ui.page.company-password-policy-list', 'ui', 'page', 'Company password policy list sayfası'),

-- ----------------------------------------------------------------
-- SECURITY_POLICY — CONTEXTS (2)
-- ----------------------------------------------------------------
('ui.context.company-pp-list-edit', 'ui', 'context', 'Company password policy edit button (list sayfası)'),
('ui.context.company-pp-reset',     'ui', 'context', 'Company password policy reset button')

ON CONFLICT (localization_key) DO NOTHING;

-- ================================================================
-- 2. ENGLISH VALUES
-- ================================================================

INSERT INTO catalog.localization_values (localization_key, language_code, value) VALUES

-- Menu Group (1)
('ui.menu-group.site-management', 'en', 'Site Management'),

-- Menus (4)
('ui.menu.site-identity',   'en', 'Site Identity'),
('ui.menu.site-content',    'en', 'Content'),
('ui.menu.site-promotions', 'en', 'Promotions'),
('ui.menu.site-lobby',      'en', 'Game Lobby'),

-- Submenus (6)
('ui.submenu.cms',        'en', 'CMS Pages'),
('ui.submenu.notices',    'en', 'Notices & Badges'),
('ui.submenu.seo',        'en', 'SEO'),
('ui.submenu.promotions', 'en', 'Promotions'),
('ui.submenu.slides',     'en', 'Slides'),
('ui.submenu.popups',     'en', 'Pop-ups'),

-- Pages (12)
('ui.page.site-settings',      'en', 'Site Settings'),
('ui.page.social-links',       'en', 'Social Links'),
('ui.page.content-list',       'en', 'Content Pages'),
('ui.page.faq-list',           'en', 'FAQ'),
('ui.page.announcement-bars',  'en', 'Announcement Bars'),
('ui.page.trust-logos',        'en', 'Trust Logos'),
('ui.page.seo-redirects',      'en', 'SEO Redirects'),
('ui.page.promotions',         'en', 'Promotions'),
('ui.page.slides',             'en', 'Slides'),
('ui.page.popups',             'en', 'Pop-ups'),
('ui.page.lobby-sections',     'en', 'Lobby Sections'),
('ui.page.game-labels',        'en', 'Game Labels'),

-- Tabs (1)
('ui.tab.tenant-licenses', 'en', 'Licenses'),

-- Contexts - Site Management (10)
('ui.context.tenant-license-add',      'en', 'Add License'),
('ui.context.social-link-create',      'en', 'Add Social Link'),
('ui.context.social-link-edit',        'en', 'Edit Social Link'),
('ui.context.announcement-bar-create', 'en', 'Create Announcement'),
('ui.context.announcement-bar-edit',   'en', 'Edit Announcement'),
('ui.context.trust-logo-create',       'en', 'Add Logo'),
('ui.context.trust-logo-edit',         'en', 'Edit Logo'),
('ui.context.lobby-section-create',    'en', 'Create Section'),
('ui.context.game-label-create',       'en', 'Create Label'),
('ui.context.seo-redirect-create',     'en', 'Add Redirect'),

-- Call Center Menus (2)
('ui.menu.support-standard', 'en', 'Support'),
('ui.menu.support-tickets',  'en', 'Ticket Management'),

-- Call Center Submenus (6)
('ui.submenu.representatives', 'en', 'Representatives'),
('ui.submenu.welcome-calls',   'en', 'Welcome Calls'),
('ui.submenu.player-notes',    'en', 'Player Notes'),
('ui.submenu.ticket-queue',    'en', 'Ticket Queue'),
('ui.submenu.ticket-config',   'en', 'Configuration'),
('ui.submenu.agent-settings',  'en', 'Agent Settings'),

-- Call Center Pages (6)
('ui.page.representative-list', 'en', 'Representatives'),
('ui.page.welcome-call-list',   'en', 'Welcome Calls'),
('ui.page.player-note-list',    'en', 'Player Notes'),
('ui.page.ticket-queue',        'en', 'Ticket Queue'),
('ui.page.ticket-config',       'en', 'Configuration'),
('ui.page.agent-settings',      'en', 'Agent Settings'),

-- Call Center Contexts (7)
('ui.context.representative-assign',   'en', 'Assign Representative'),
('ui.context.welcome-call-assign',     'en', 'Take Task'),
('ui.context.player-note-create',      'en', 'Add Note'),
('ui.context.ticket-create',           'en', 'Create Ticket'),
('ui.context.ticket-assign',           'en', 'Assign Ticket'),
('ui.context.ticket-category-create',  'en', 'Create Category'),
('ui.context.canned-response-create',  'en', 'Create Template'),

-- Security Policy - Submenus (2)
('ui.submenu.company-list',      'en', 'Companies'),
('ui.submenu.password-policies', 'en', 'Password Policies'),

-- Security Policy - Page (1)
('ui.page.company-password-policy-list', 'en', 'Password Policies'),

-- Security Policy - Contexts (2)
('ui.context.company-pp-list-edit', 'en', 'Edit Policy'),
('ui.context.company-pp-reset',     'en', 'Reset to Default')

ON CONFLICT (localization_key, language_code) DO NOTHING;

-- ================================================================
-- 3. TURKISH VALUES (tr)
-- ================================================================

INSERT INTO catalog.localization_values (localization_key, language_code, value) VALUES

-- Menu Group (1)
('ui.menu-group.site-management', 'tr', 'Site Yönetimi'),

-- Menus (4)
('ui.menu.site-identity',   'tr', 'Site Kimliği'),
('ui.menu.site-content',    'tr', 'İçerik'),
('ui.menu.site-promotions', 'tr', 'Promosyonlar'),
('ui.menu.site-lobby',      'tr', 'Oyun Lobisi'),

-- Submenus (6)
('ui.submenu.cms',        'tr', 'CMS Sayfaları'),
('ui.submenu.notices',    'tr', 'Duyurular & Rozetler'),
('ui.submenu.seo',        'tr', 'SEO'),
('ui.submenu.promotions', 'tr', 'Promosyonlar'),
('ui.submenu.slides',     'tr', 'Slaytlar'),
('ui.submenu.popups',     'tr', 'Pop-up''lar'),

-- Pages (12)
('ui.page.site-settings',      'tr', 'Site Ayarları'),
('ui.page.social-links',       'tr', 'Sosyal Linkler'),
('ui.page.content-list',       'tr', 'İçerik Sayfaları'),
('ui.page.faq-list',           'tr', 'SSS'),
('ui.page.announcement-bars',  'tr', 'Duyuru Çubukları'),
('ui.page.trust-logos',        'tr', 'Güven Logoları'),
('ui.page.seo-redirects',      'tr', 'SEO Yönlendirmeleri'),
('ui.page.promotions',         'tr', 'Promosyonlar'),
('ui.page.slides',             'tr', 'Slaytlar'),
('ui.page.popups',             'tr', 'Pop-up''lar'),
('ui.page.lobby-sections',     'tr', 'Lobi Bölümleri'),
('ui.page.game-labels',        'tr', 'Oyun Etiketleri'),

-- Tabs (1)
('ui.tab.tenant-licenses', 'tr', 'Lisanslar'),

-- Contexts - Site Management (10)
('ui.context.tenant-license-add',      'tr', 'Lisans Ekle'),
('ui.context.social-link-create',      'tr', 'Sosyal Link Ekle'),
('ui.context.social-link-edit',        'tr', 'Sosyal Linki Düzenle'),
('ui.context.announcement-bar-create', 'tr', 'Duyuru Oluştur'),
('ui.context.announcement-bar-edit',   'tr', 'Duyuruyu Düzenle'),
('ui.context.trust-logo-create',       'tr', 'Logo Ekle'),
('ui.context.trust-logo-edit',         'tr', 'Logoyu Düzenle'),
('ui.context.lobby-section-create',    'tr', 'Bölüm Oluştur'),
('ui.context.game-label-create',       'tr', 'Etiket Oluştur'),
('ui.context.seo-redirect-create',     'tr', 'Yönlendirme Ekle'),

-- Call Center Menüler (2)
('ui.menu.support-standard', 'tr', 'Destek'),
('ui.menu.support-tickets',  'tr', 'Ticket Yönetimi'),

-- Call Center Alt Menüler (6)
('ui.submenu.representatives', 'tr', 'Temsilciler'),
('ui.submenu.welcome-calls',   'tr', 'Hoşgeldin Aramaları'),
('ui.submenu.player-notes',    'tr', 'Oyuncu Notları'),
('ui.submenu.ticket-queue',    'tr', 'Ticket Kuyruğu'),
('ui.submenu.ticket-config',   'tr', 'Yapılandırma'),
('ui.submenu.agent-settings',  'tr', 'Agent Ayarları'),

-- Call Center Sayfalar (6)
('ui.page.representative-list', 'tr', 'Temsilciler'),
('ui.page.welcome-call-list',   'tr', 'Hoşgeldin Aramaları'),
('ui.page.player-note-list',    'tr', 'Oyuncu Notları'),
('ui.page.ticket-queue',        'tr', 'Ticket Kuyruğu'),
('ui.page.ticket-config',       'tr', 'Yapılandırma'),
('ui.page.agent-settings',      'tr', 'Agent Ayarları'),

-- Call Center Context'ler (7)
('ui.context.representative-assign',   'tr', 'Temsilci Ata'),
('ui.context.welcome-call-assign',     'tr', 'Görevi Al'),
('ui.context.player-note-create',      'tr', 'Not Ekle'),
('ui.context.ticket-create',           'tr', 'Ticket Oluştur'),
('ui.context.ticket-assign',           'tr', 'Ticket Ata'),
('ui.context.ticket-category-create',  'tr', 'Kategori Oluştur'),
('ui.context.canned-response-create',  'tr', 'Şablon Oluştur'),

-- Security Policy - Submenüler (2)
('ui.submenu.company-list',      'tr', 'Şirketler'),
('ui.submenu.password-policies', 'tr', 'Şifre Politikaları'),

-- Security Policy - Sayfa (1)
('ui.page.company-password-policy-list', 'tr', 'Şifre Politikaları'),

-- Security Policy - Context'ler (2)
('ui.context.company-pp-list-edit', 'tr', 'Politikayı Düzenle'),
('ui.context.company-pp-reset',     'tr', 'Varsayılana Döndür')

ON CONFLICT (localization_key, language_code) DO NOTHING;
