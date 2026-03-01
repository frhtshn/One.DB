-- =============================================
-- Tablo: presentation.navigation
-- Açıklama: Frontend navigasyon yönetimi.
--           Header, Footer, Sidebar, Mobile Menu vb.
--           Core'dan taşındı (client_id kaldırıldı).
--           Provisioning ile template öğeleri kopyalanır.
-- =============================================

DROP TABLE IF EXISTS presentation.navigation CASCADE;

CREATE TABLE presentation.navigation (
    id BIGSERIAL PRIMARY KEY,

    -- Master Data Bağlantısı (Opsiyonel)
    template_item_id BIGINT,                              -- Catalog'daki master öğe ID'si (catalog.navigation_template_items)

    menu_location VARCHAR(50) NOT NULL,                   -- Menü konumu: main_header, footer_col_1, sidebar, mobile_bottom

    -- Menü Metni (Hibrit Lokalizasyon)
    translation_key VARCHAR(100),                         -- Sistem çevirisi için key: 'menu.main.home'
    custom_label JSONB,                                   -- Client override veya özel metin: {"en": "My Home", "tr": "Evim"}

    icon VARCHAR(50),                                     -- İkon (fa-home, custom-icon)
    badge_text VARCHAR(20),                               -- Badge (NEW, HOT)
    badge_color VARCHAR(20),                              -- Badge rengi (#ff0000)

    -- Hedef (Link/Aksiyon)
    target_type VARCHAR(20) NOT NULL DEFAULT 'internal',  -- internal, external, action, route
    target_url VARCHAR(255),                              -- Link: /casino, https://google.com
    target_action VARCHAR(50),                            -- Aksiyon: open_login_modal, toggle_theme
    open_in_new_tab BOOLEAN DEFAULT FALSE,                -- Yeni sekmede aç?

    -- Hiyerarşi
    parent_id BIGINT,                                     -- Alt menü ise parent ID
    display_order INT DEFAULT 0,                          -- Sıralama

    -- Görünürlük Kuralları
    is_visible BOOLEAN DEFAULT TRUE,                      -- Aktif mi?
    requires_auth BOOLEAN DEFAULT FALSE,                  -- Sadece login olanlara göster
    requires_guest BOOLEAN DEFAULT FALSE,                 -- Sadece login OLMAYANLARA göster (Login btn)
    required_roles VARCHAR(50)[],                         -- Opsiyonel: Sadece VIP kullanıcılar vb.

    device_visibility VARCHAR(20) DEFAULT 'all',          -- all, mobile_only, desktop_only

    -- Korumalar (Master Data Yönetimi)
    is_locked BOOLEAN DEFAULT FALSE,                      -- TRUE = Client bu kaydı SİLEMEZ (Master'dan geldi)
    is_readonly BOOLEAN DEFAULT FALSE,                    -- TRUE = Client target/type/action değiştiremez

    custom_css_class VARCHAR(100),                        -- Özel CSS sınıfı

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE presentation.navigation IS 'Dynamic frontend navigation management. Can be derived from catalog templates via provisioning.';
