-- ============================================================================
-- NUCLEO PLATFORM — UIKit Katalog Seed
-- ============================================================================
-- İlk site açılışı için varsayılan temalar, widget'lar, UI pozisyonları
-- ve navigasyon şablonları.
-- UPSERT: ON CONFLICT kullanır — idempotent, production-safe.
-- ============================================================================

-- ============================================================================
-- 1. TEMALAR (catalog.themes)
-- ============================================================================

INSERT INTO catalog.themes (id, code, name, description, version, thumbnail_url, default_config, is_active, is_premium)
VALUES
(1, 'dark_neon', 'Dark Neon', 'Dark theme with neon accents — iGaming classic', '1.0.0', NULL,
 '{
   "colors": {
     "primary": "#00e676",
     "secondary": "#ff6f00",
     "background": "#0d0d0d",
     "surface": "#1a1a2e",
     "text": "#f5f5f5",
     "textMuted": "#9e9e9e",
     "accent": "#7c4dff",
     "success": "#00c853",
     "warning": "#ffd600",
     "danger": "#f44336"
   },
   "fonts": {
     "header": "Rajdhani, sans-serif",
     "body": "Inter, sans-serif"
   },
   "borderRadius": "8px",
   "cardStyle": "elevated"
 }'::jsonb, true, false),

(2, 'classic_blue', 'Classic Blue', 'Clean professional blue theme', '1.0.0', NULL,
 '{
   "colors": {
     "primary": "#1565c0",
     "secondary": "#f57c00",
     "background": "#f8fafc",
     "surface": "#ffffff",
     "text": "#1a1a1a",
     "textMuted": "#6b7280",
     "accent": "#0288d1",
     "success": "#2e7d32",
     "warning": "#f57f17",
     "danger": "#c62828"
   },
   "fonts": {
     "header": "Montserrat, sans-serif",
     "body": "Open Sans, sans-serif"
   },
   "borderRadius": "4px",
   "cardStyle": "outlined"
 }'::jsonb, true, false)

ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    version = EXCLUDED.version,
    default_config = EXCLUDED.default_config,
    is_active = EXCLUDED.is_active,
    is_premium = EXCLUDED.is_premium,
    updated_at = NOW();

SELECT setval('catalog.themes_id_seq', GREATEST((SELECT MAX(id) FROM catalog.themes), 1));

-- ============================================================================
-- 2. WIDGET'LAR (catalog.widgets)
-- ============================================================================

INSERT INTO catalog.widgets (id, code, name, description, category, component_name, default_props, is_active)
VALUES
-- NAVIGATION
(1,  'logo',              'Site Logo',                'Site logosu ve ana sayfaya link',             'NAVIGATION', 'SiteLogo',
 '{"height": 48, "linkTo": "/"}'::jsonb, true),

(2,  'main_menu',         'Main Navigation Menu',     'Ana yatay navigasyon menüsü',                'NAVIGATION', 'MainMenu',
 '{"orientation": "horizontal"}'::jsonb, true),

(3,  'footer_links',      'Footer Link Columns',      'Footer link kolonları',                      'NAVIGATION', 'FooterLinks',
 '{"columns": 4}'::jsonb, true),

(4,  'mobile_bottom_nav', 'Mobile Bottom Navigation', 'Mobil alt navigasyon çubuğu',                'NAVIGATION', 'MobileBottomNav',
 '{"items": 5}'::jsonb, true),

-- ACCOUNT
(5,  'user_actions',      'User Action Bar',          'Bakiye, yatırım, giriş/kayıt butonları',    'ACCOUNT',    'UserActionBar',
 '{"showBalance": true, "showDeposit": true}'::jsonb, true),

-- CONTENT
(6,  'hero_banner',       'Hero Banner / Slider',     'Ana sayfa banner/slider alanı',              'CONTENT',    'HeroBanner',
 '{"autoplay": true, "interval": 5000, "height": 480}'::jsonb, true),

(7,  'promotions_grid',   'Promotions Grid',          'Promosyon kartları ızgarası',                'CONTENT',    'PromotionsGrid',
 '{"columns": 3, "showExpiry": true}'::jsonb, true),

(8,  'live_score_bar',    'Live Score Ticker',        'Canlı skor ticker çubuğu',                  'CONTENT',    'LiveScoreBar',
 '{"sports": ["football", "basketball", "tennis"]}'::jsonb, true),

(9,  'footer_branding',   'Footer Branding',          'Lisans, ödeme yöntemleri ve telif bilgisi',  'CONTENT',    'FooterBranding',
 '{"showLicenses": true, "showPaymentMethods": true}'::jsonb, true),

-- GAME
(10, 'game_categories',   'Game Category Tabs',       'Oyun kategorileri tab menüsü',               'GAME',       'GameCategoryTabs',
 '{"showIcons": true, "scrollable": true}'::jsonb, true),

(11, 'game_grid',         'Game Grid',                'Oyun listesi ızgarası',                      'GAME',       'GameGrid',
 '{"columns": 6, "rows": 3, "showProvider": true}'::jsonb, true),

(12, 'featured_games',    'Featured Games Carousel',  'Öne çıkan oyunlar carousel',                 'GAME',       'FeaturedGamesCarousel',
 '{"count": 8, "autoScroll": true}'::jsonb, true),

(13, 'jackpot_ticker',    'Jackpot Ticker',           'Jackpot miktarı animasyonlu ticker',         'GAME',       'JackpotTicker',
 '{"currency": "EUR", "animated": true}'::jsonb, true),

(14, 'search_bar',        'Game Search Bar',          'Oyun arama çubuğu',                          'GAME',       'GameSearchBar',
 '{"placeholder": "Search games...", "instant": true}'::jsonb, true),

(15, 'recent_winners',    'Recent Winners Feed',      'Son kazananlar canlı akışı',                 'GAME',       'RecentWinnersFeed',
 '{"count": 10, "animated": true}'::jsonb, true)

ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    category = EXCLUDED.category,
    component_name = EXCLUDED.component_name,
    default_props = EXCLUDED.default_props,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

SELECT setval('catalog.widgets_id_seq', GREATEST((SELECT MAX(id) FROM catalog.widgets), 1));

-- ============================================================================
-- 3. UI POZİSYONLARI (catalog.ui_positions)
-- ============================================================================

INSERT INTO catalog.ui_positions (id, code, name, is_global)
VALUES
(1,  'header_top',        'Header Top Bar',           true),
(2,  'header_main',       'Header Main',              true),
(3,  'header_secondary',  'Header Secondary Bar',     true),
(4,  'sidebar_left',      'Left Sidebar',             false),
(5,  'sidebar_right',     'Right Sidebar',            false),
(6,  'main_hero',         'Main Hero Area',           false),
(7,  'main_content',      'Main Content Area',        false),
(8,  'main_secondary',    'Secondary Content Area',   false),
(9,  'footer_top',        'Footer Top Bar',           true),
(10, 'footer_main',       'Footer Main',              true),
(11, 'footer_bottom',     'Footer Bottom Bar',        true),
(12, 'mobile_bottom',     'Mobile Bottom Bar',        true)

ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    is_global = EXCLUDED.is_global,
    updated_at = NOW();

SELECT setval('catalog.ui_positions_id_seq', GREATEST((SELECT MAX(id) FROM catalog.ui_positions), 1));

-- ============================================================================
-- 4. NAVİGASYON ŞABLONLARI (catalog.navigation_templates)
-- ============================================================================

INSERT INTO catalog.navigation_templates (id, code, name, description, is_active, is_default)
VALUES
(1, 'casino_sportsbook', 'Casino + Sportsbook', 'Casino ve spor bahis sitesi için varsayılan navigasyon şablonu', true, true),
(2, 'casino_only',       'Casino Only',         'Sadece casino sitesi için navigasyon şablonu',                   true, false)

ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    is_active = EXCLUDED.is_active,
    is_default = EXCLUDED.is_default,
    updated_at = NOW();

SELECT setval('catalog.navigation_templates_id_seq', GREATEST((SELECT MAX(id) FROM catalog.navigation_templates), 1));

-- ============================================================================
-- 5. NAVİGASYON ŞABLON ÖĞELERİ (catalog.navigation_template_items)
-- ============================================================================
-- Strateji: DELETE + INSERT (template bazlı scope)
-- navigation_template_items'da code UNIQUE yok, UPSERT kullanılamaz.
-- Sadece bizim template'lere ait öğeler silinip yeniden eklenir.
-- ============================================================================

DELETE FROM catalog.navigation_template_items
WHERE template_id IN (
    SELECT id FROM catalog.navigation_templates WHERE code IN ('casino_sportsbook', 'casino_only')
);

-- ────────────────────────────────────────────────────────────────────────────
-- 5.1 CASINO + SPORTSBOOK ŞABLONU (template_id = 1, ID'ler: 1-70)
-- ────────────────────────────────────────────────────────────────────────────

INSERT INTO catalog.navigation_template_items
(id, template_id, menu_location, translation_key, default_label, icon, target_type, target_url, target_action, parent_id, display_order, is_locked, is_mandatory)
VALUES

-- ── main_header: Root öğeler ──────────────────────────────────────────────
(1,  1, 'main_header', 'menu.main.casino',      '{"en": "Casino", "tr": "Casino"}'::jsonb,
 'casino',      'internal', '/casino',       NULL, NULL, 1,  true,  true),

(2,  1, 'main_header', 'menu.main.live-casino', '{"en": "Live Casino", "tr": "Canlı Casino"}'::jsonb,
 'live-casino', 'internal', '/live-casino',  NULL, NULL, 2,  true,  true),

(3,  1, 'main_header', 'menu.main.sports',      '{"en": "Sports", "tr": "Spor"}'::jsonb,
 'sports',      'internal', '/sports',       NULL, NULL, 3,  true,  false),

(4,  1, 'main_header', 'menu.main.promotions',  '{"en": "Promotions", "tr": "Promosyonlar"}'::jsonb,
 'promotions',  'internal', '/promotions',   NULL, NULL, 4,  false, false),

(5,  1, 'main_header', 'menu.main.tournaments', '{"en": "Tournaments", "tr": "Turnuvalar"}'::jsonb,
 'tournaments', 'internal', '/tournaments',  NULL, NULL, 5,  false, false),

(6,  1, 'main_header', 'menu.main.vip',         '{"en": "VIP", "tr": "VIP"}'::jsonb,
 'vip',         'internal', '/vip',          NULL, NULL, 6,  false, false),

(7,  1, 'main_header', 'menu.main.login',       '{"en": "Login", "tr": "Giriş"}'::jsonb,
 'login',       'action',   NULL,  'open_login_modal',    NULL, 7,  true,  true),

(8,  1, 'main_header', 'menu.main.register',    '{"en": "Register", "tr": "Kayıt Ol"}'::jsonb,
 'register',    'action',   NULL,  'open_register_modal', NULL, 8,  true,  true),

-- ── main_header: Casino alt menü (parent_id = 1) ─────────────────────────
(9,  1, 'main_header', 'menu.casino.slots',       '{"en": "Slots", "tr": "Slot Oyunları"}'::jsonb,
 'slots',       'internal', '/casino/slots',       NULL, 1, 1, false, false),

(10, 1, 'main_header', 'menu.casino.table-games', '{"en": "Table Games", "tr": "Masa Oyunları"}'::jsonb,
 'table-games', 'internal', '/casino/table-games', NULL, 1, 2, false, false),

(11, 1, 'main_header', 'menu.casino.jackpots',    '{"en": "Jackpots", "tr": "Jackpot"}'::jsonb,
 'jackpot',     'internal', '/casino/jackpots',    NULL, 1, 3, false, false),

(12, 1, 'main_header', 'menu.casino.new-games',   '{"en": "New Games", "tr": "Yeni Oyunlar"}'::jsonb,
 'new',         'internal', '/casino/new',         NULL, 1, 4, false, false),

-- ── main_header: Live Casino alt menü (parent_id = 2) ────────────────────
(13, 1, 'main_header', 'menu.live-casino.roulette',  '{"en": "Live Roulette", "tr": "Canlı Rulet"}'::jsonb,
 'roulette',  'internal', '/live-casino/roulette',  NULL, 2, 1, false, false),

(14, 1, 'main_header', 'menu.live-casino.blackjack', '{"en": "Live Blackjack", "tr": "Canlı Blackjack"}'::jsonb,
 'blackjack', 'internal', '/live-casino/blackjack', NULL, 2, 2, false, false),

(15, 1, 'main_header', 'menu.live-casino.baccarat',  '{"en": "Live Baccarat", "tr": "Canlı Baccarat"}'::jsonb,
 'baccarat',  'internal', '/live-casino/baccarat',  NULL, 2, 3, false, false),

(16, 1, 'main_header', 'menu.live-casino.game-shows','{"en": "Game Shows", "tr": "Oyun Şovları"}'::jsonb,
 'game-shows','internal', '/live-casino/game-shows',NULL, 2, 4, false, false),

-- ── main_header: Sports alt menü (parent_id = 3) ─────────────────────────
(17, 1, 'main_header', 'menu.sports.football',    '{"en": "Football", "tr": "Futbol"}'::jsonb,
 'football',    'internal', '/sports/football',    NULL, 3, 1, false, false),

(18, 1, 'main_header', 'menu.sports.basketball',  '{"en": "Basketball", "tr": "Basketbol"}'::jsonb,
 'basketball',  'internal', '/sports/basketball',  NULL, 3, 2, false, false),

(19, 1, 'main_header', 'menu.sports.tennis',      '{"en": "Tennis", "tr": "Tenis"}'::jsonb,
 'tennis',      'internal', '/sports/tennis',      NULL, 3, 3, false, false),

(20, 1, 'main_header', 'menu.sports.live',        '{"en": "Live Betting", "tr": "Canlı Bahis"}'::jsonb,
 'live',        'internal', '/sports/live',        NULL, 3, 4, false, false),

-- ── footer_col_1: Şirket Bilgileri ───────────────────────────────────────
(21, 1, 'footer_col_1', 'menu.footer.about',              '{"en": "About Us", "tr": "Hakkımızda"}'::jsonb,
 NULL, 'internal', '/about',              NULL, NULL, 1, false, false),

(22, 1, 'footer_col_1', 'menu.footer.responsible-gaming', '{"en": "Responsible Gaming", "tr": "Sorumlu Oyun"}'::jsonb,
 NULL, 'internal', '/responsible-gaming', NULL, NULL, 2, true,  true),

(23, 1, 'footer_col_1', 'menu.footer.privacy',            '{"en": "Privacy Policy", "tr": "Gizlilik Politikası"}'::jsonb,
 NULL, 'internal', '/privacy',            NULL, NULL, 3, true,  true),

(24, 1, 'footer_col_1', 'menu.footer.terms',              '{"en": "Terms & Conditions", "tr": "Şartlar ve Koşullar"}'::jsonb,
 NULL, 'internal', '/terms',              NULL, NULL, 4, true,  true),

-- ── footer_col_2: Oyunlar ────────────────────────────────────────────────
(25, 1, 'footer_col_2', 'menu.footer.casino',      '{"en": "Casino", "tr": "Casino"}'::jsonb,
 NULL, 'internal', '/casino',      NULL, NULL, 1, false, false),

(26, 1, 'footer_col_2', 'menu.footer.live-casino', '{"en": "Live Casino", "tr": "Canlı Casino"}'::jsonb,
 NULL, 'internal', '/live-casino', NULL, NULL, 2, false, false),

(27, 1, 'footer_col_2', 'menu.footer.sports',      '{"en": "Sports", "tr": "Spor"}'::jsonb,
 NULL, 'internal', '/sports',      NULL, NULL, 3, false, false),

(28, 1, 'footer_col_2', 'menu.footer.promotions',  '{"en": "Promotions", "tr": "Promosyonlar"}'::jsonb,
 NULL, 'internal', '/promotions',  NULL, NULL, 4, false, false),

-- ── footer_col_3: Destek ─────────────────────────────────────────────────
(29, 1, 'footer_col_3', 'menu.footer.help',        '{"en": "Help Center", "tr": "Yardım Merkezi"}'::jsonb,
 NULL, 'internal', '/help',        NULL, NULL, 1, false, false),

(30, 1, 'footer_col_3', 'menu.footer.contact',     '{"en": "Contact Us", "tr": "Bize Ulaşın"}'::jsonb,
 NULL, 'internal', '/contact',     NULL, NULL, 2, false, false),

(31, 1, 'footer_col_3', 'menu.footer.affiliates',  '{"en": "Affiliates", "tr": "İş Ortaklığı"}'::jsonb,
 NULL, 'internal', '/affiliates',  NULL, NULL, 3, false, false),

-- ── footer_col_4: Hesap ──────────────────────────────────────────────────
(32, 1, 'footer_col_4', 'menu.footer.account',  '{"en": "My Account", "tr": "Hesabım"}'::jsonb,
 NULL, 'internal', '/account',  NULL, NULL, 1, false, false),

(33, 1, 'footer_col_4', 'menu.footer.deposit',  '{"en": "Deposit", "tr": "Para Yatır"}'::jsonb,
 NULL, 'action',   NULL, 'open_deposit_modal',    NULL, 2, false, false),

(34, 1, 'footer_col_4', 'menu.footer.withdraw', '{"en": "Withdraw", "tr": "Para Çek"}'::jsonb,
 NULL, 'action',   NULL, 'open_withdrawal_modal', NULL, 3, false, false),

-- ── mobile_bottom: Mobil alt navigasyon ──────────────────────────────────
(35, 1, 'mobile_bottom', 'menu.mobile.home',       '{"en": "Home", "tr": "Ana Sayfa"}'::jsonb,
 'home',       'internal', '/',            NULL, NULL, 1, true,  true),

(36, 1, 'mobile_bottom', 'menu.mobile.casino',     '{"en": "Casino", "tr": "Casino"}'::jsonb,
 'casino',     'internal', '/casino',      NULL, NULL, 2, true,  true),

(37, 1, 'mobile_bottom', 'menu.mobile.sports',     '{"en": "Sports", "tr": "Spor"}'::jsonb,
 'sports',     'internal', '/sports',      NULL, NULL, 3, true,  false),

(38, 1, 'mobile_bottom', 'menu.mobile.promotions', '{"en": "Promotions", "tr": "Promosyonlar"}'::jsonb,
 'promotions', 'internal', '/promotions',  NULL, NULL, 4, false, false),

(39, 1, 'mobile_bottom', 'menu.mobile.account',    '{"en": "My Account", "tr": "Hesabım"}'::jsonb,
 'account',    'action',   NULL, 'open_account_menu', NULL, 5, true,  true);


-- ────────────────────────────────────────────────────────────────────────────
-- 5.2 CASINO ONLY ŞABLONU (template_id = 2, ID'ler: 101-160)
-- ────────────────────────────────────────────────────────────────────────────

INSERT INTO catalog.navigation_template_items
(id, template_id, menu_location, translation_key, default_label, icon, target_type, target_url, target_action, parent_id, display_order, is_locked, is_mandatory)
VALUES

-- ── main_header: Root öğeler (Sports yok) ─────────────────────────────────
(101, 2, 'main_header', 'menu.main.casino',      '{"en": "Casino", "tr": "Casino"}'::jsonb,
 'casino',      'internal', '/casino',       NULL, NULL,  1,  true,  true),

(102, 2, 'main_header', 'menu.main.live-casino', '{"en": "Live Casino", "tr": "Canlı Casino"}'::jsonb,
 'live-casino', 'internal', '/live-casino',  NULL, NULL,  2,  true,  true),

(103, 2, 'main_header', 'menu.main.promotions',  '{"en": "Promotions", "tr": "Promosyonlar"}'::jsonb,
 'promotions',  'internal', '/promotions',   NULL, NULL,  3,  false, false),

(104, 2, 'main_header', 'menu.main.tournaments', '{"en": "Tournaments", "tr": "Turnuvalar"}'::jsonb,
 'tournaments', 'internal', '/tournaments',  NULL, NULL,  4,  false, false),

(105, 2, 'main_header', 'menu.main.vip',         '{"en": "VIP", "tr": "VIP"}'::jsonb,
 'vip',         'internal', '/vip',          NULL, NULL,  5,  false, false),

(106, 2, 'main_header', 'menu.main.login',       '{"en": "Login", "tr": "Giriş"}'::jsonb,
 'login',       'action',   NULL,  'open_login_modal',    NULL,  6,  true,  true),

(107, 2, 'main_header', 'menu.main.register',    '{"en": "Register", "tr": "Kayıt Ol"}'::jsonb,
 'register',    'action',   NULL,  'open_register_modal', NULL,  7,  true,  true),

-- ── main_header: Casino alt menü (parent_id = 101) ───────────────────────
(108, 2, 'main_header', 'menu.casino.slots',       '{"en": "Slots", "tr": "Slot Oyunları"}'::jsonb,
 'slots',       'internal', '/casino/slots',       NULL, 101, 1, false, false),

(109, 2, 'main_header', 'menu.casino.table-games', '{"en": "Table Games", "tr": "Masa Oyunları"}'::jsonb,
 'table-games', 'internal', '/casino/table-games', NULL, 101, 2, false, false),

(110, 2, 'main_header', 'menu.casino.jackpots',    '{"en": "Jackpots", "tr": "Jackpot"}'::jsonb,
 'jackpot',     'internal', '/casino/jackpots',    NULL, 101, 3, false, false),

(111, 2, 'main_header', 'menu.casino.new-games',   '{"en": "New Games", "tr": "Yeni Oyunlar"}'::jsonb,
 'new',         'internal', '/casino/new',         NULL, 101, 4, false, false),

-- ── main_header: Live Casino alt menü (parent_id = 102) ──────────────────
(112, 2, 'main_header', 'menu.live-casino.roulette',  '{"en": "Live Roulette", "tr": "Canlı Rulet"}'::jsonb,
 'roulette',  'internal', '/live-casino/roulette',  NULL, 102, 1, false, false),

(113, 2, 'main_header', 'menu.live-casino.blackjack', '{"en": "Live Blackjack", "tr": "Canlı Blackjack"}'::jsonb,
 'blackjack', 'internal', '/live-casino/blackjack', NULL, 102, 2, false, false),

(114, 2, 'main_header', 'menu.live-casino.baccarat',  '{"en": "Live Baccarat", "tr": "Canlı Baccarat"}'::jsonb,
 'baccarat',  'internal', '/live-casino/baccarat',  NULL, 102, 3, false, false),

(115, 2, 'main_header', 'menu.live-casino.game-shows','{"en": "Game Shows", "tr": "Oyun Şovları"}'::jsonb,
 'game-shows','internal', '/live-casino/game-shows',NULL, 102, 4, false, false),

-- ── footer_col_1: Şirket Bilgileri ───────────────────────────────────────
(116, 2, 'footer_col_1', 'menu.footer.about',              '{"en": "About Us", "tr": "Hakkımızda"}'::jsonb,
 NULL, 'internal', '/about',              NULL, NULL, 1, false, false),

(117, 2, 'footer_col_1', 'menu.footer.responsible-gaming', '{"en": "Responsible Gaming", "tr": "Sorumlu Oyun"}'::jsonb,
 NULL, 'internal', '/responsible-gaming', NULL, NULL, 2, true,  true),

(118, 2, 'footer_col_1', 'menu.footer.privacy',            '{"en": "Privacy Policy", "tr": "Gizlilik Politikası"}'::jsonb,
 NULL, 'internal', '/privacy',            NULL, NULL, 3, true,  true),

(119, 2, 'footer_col_1', 'menu.footer.terms',              '{"en": "Terms & Conditions", "tr": "Şartlar ve Koşullar"}'::jsonb,
 NULL, 'internal', '/terms',              NULL, NULL, 4, true,  true),

-- ── footer_col_2: Oyunlar (Sports yok) ───────────────────────────────────
(120, 2, 'footer_col_2', 'menu.footer.casino',      '{"en": "Casino", "tr": "Casino"}'::jsonb,
 NULL, 'internal', '/casino',      NULL, NULL, 1, false, false),

(121, 2, 'footer_col_2', 'menu.footer.live-casino', '{"en": "Live Casino", "tr": "Canlı Casino"}'::jsonb,
 NULL, 'internal', '/live-casino', NULL, NULL, 2, false, false),

(122, 2, 'footer_col_2', 'menu.footer.promotions',  '{"en": "Promotions", "tr": "Promosyonlar"}'::jsonb,
 NULL, 'internal', '/promotions',  NULL, NULL, 3, false, false),

-- ── footer_col_3: Destek ─────────────────────────────────────────────────
(123, 2, 'footer_col_3', 'menu.footer.help',        '{"en": "Help Center", "tr": "Yardım Merkezi"}'::jsonb,
 NULL, 'internal', '/help',        NULL, NULL, 1, false, false),

(124, 2, 'footer_col_3', 'menu.footer.contact',     '{"en": "Contact Us", "tr": "Bize Ulaşın"}'::jsonb,
 NULL, 'internal', '/contact',     NULL, NULL, 2, false, false),

(125, 2, 'footer_col_3', 'menu.footer.affiliates',  '{"en": "Affiliates", "tr": "İş Ortaklığı"}'::jsonb,
 NULL, 'internal', '/affiliates',  NULL, NULL, 3, false, false),

-- ── footer_col_4: Hesap ──────────────────────────────────────────────────
(126, 2, 'footer_col_4', 'menu.footer.account',  '{"en": "My Account", "tr": "Hesabım"}'::jsonb,
 NULL, 'internal', '/account',  NULL, NULL, 1, false, false),

(127, 2, 'footer_col_4', 'menu.footer.deposit',  '{"en": "Deposit", "tr": "Para Yatır"}'::jsonb,
 NULL, 'action',   NULL, 'open_deposit_modal',    NULL, 2, false, false),

(128, 2, 'footer_col_4', 'menu.footer.withdraw', '{"en": "Withdraw", "tr": "Para Çek"}'::jsonb,
 NULL, 'action',   NULL, 'open_withdrawal_modal', NULL, 3, false, false),

-- ── mobile_bottom: Mobil alt navigasyon (Sports yok) ─────────────────────
(129, 2, 'mobile_bottom', 'menu.mobile.home',       '{"en": "Home", "tr": "Ana Sayfa"}'::jsonb,
 'home',       'internal', '/',            NULL, NULL, 1, true,  true),

(130, 2, 'mobile_bottom', 'menu.mobile.casino',     '{"en": "Casino", "tr": "Casino"}'::jsonb,
 'casino',     'internal', '/casino',      NULL, NULL, 2, true,  true),

(131, 2, 'mobile_bottom', 'menu.mobile.promotions', '{"en": "Promotions", "tr": "Promosyonlar"}'::jsonb,
 'promotions', 'internal', '/promotions',  NULL, NULL, 3, false, false),

(132, 2, 'mobile_bottom', 'menu.mobile.account',    '{"en": "My Account", "tr": "Hesabım"}'::jsonb,
 'account',    'action',   NULL, 'open_account_menu', NULL, 4, true,  true);

SELECT setval('catalog.navigation_template_items_id_seq',
    GREATEST((SELECT MAX(id) FROM catalog.navigation_template_items), 200));


-- ============================================================================
-- 6. DOĞRULAMA
-- ============================================================================

DO $$
DECLARE
    v_themes    INT;
    v_widgets   INT;
    v_positions INT;
    v_templates INT;
    v_items     INT;
BEGIN
    SELECT COUNT(*) INTO v_themes    FROM catalog.themes;
    SELECT COUNT(*) INTO v_widgets   FROM catalog.widgets;
    SELECT COUNT(*) INTO v_positions FROM catalog.ui_positions;
    SELECT COUNT(*) INTO v_templates FROM catalog.navigation_templates;
    SELECT COUNT(*) INTO v_items     FROM catalog.navigation_template_items;

    RAISE NOTICE 'UIKIT SEED: themes=% widgets=% positions=% templates=% items=%',
        v_themes, v_widgets, v_positions, v_templates, v_items;
END $$;
