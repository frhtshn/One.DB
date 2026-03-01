-- =============================================
-- Client Navigation (Site Menüleri)
-- Client'ın frontend navigasyon yönetimi
-- Header, Footer, Sidebar, Mobile Menu vb.
-- =============================================

DROP TABLE IF EXISTS presentation.client_navigation CASCADE;

CREATE TABLE presentation.client_navigation (
    id bigserial PRIMARY KEY,
    client_id bigint NOT NULL,                            -- Hangi client

    -- Master Data Bağlantısı (Opsiyonel)
    template_item_id bigint,                              -- Catalog'daki master öğe ID'si (catalog.navigation_template_items)

    menu_location varchar(50) NOT NULL,                   -- Menü konumu: main_header, footer_col_1, sidebar, mobile_bottom

    -- Menü Metni (Hibrit Lokalizasyon)
    translation_key varchar(100),                         -- Sistem çevirisi için key: 'menu.main.home'
    custom_label jsonb,                                   -- Client override veya özel metin: {"en": "My Home", "tr": "Evim"}

    icon varchar(50),                                     -- İkon (fa-home, custom-icon)
    badge_text varchar(20),                               -- Badge (NEW, HOT)
    badge_color varchar(20),                              -- Badge rengi (#ff0000)

    -- Hedef (Link/Aksiyon)
    target_type varchar(20) NOT NULL DEFAULT 'internal',  -- internal, external, action, route
    target_url varchar(255),                              -- Link: /casino, https://google.com
    target_action varchar(50),                            -- Aksiyon: open_login_modal, toggle_theme
    open_in_new_tab boolean DEFAULT false,                -- Yeni sekmede aç?

    -- Hiyerarşi
    parent_id bigint,                                     -- Alt menü ise parent ID
    display_order int DEFAULT 0,                          -- Sıralama

    -- Görünürlük Kuralları
    is_visible boolean DEFAULT true,                      -- Aktif mi?
    requires_auth boolean DEFAULT false,                  -- Sadece login olanlara göster
    requires_guest boolean DEFAULT false,                 -- Sadece login OLMAYANLARA göster (Login btn)
    required_roles varchar(50)[],                         -- Opsiyonel: Sadece VIP userlar vb.

    device_visibility varchar(20) DEFAULT 'all',          -- all, mobile_only, desktop_only

    -- Korumalar (Master Data Yönetimi)
    is_locked boolean DEFAULT false,                      -- True = Client bu kaydı SİLEMEZ (Master'dan geldi)
    is_readonly boolean DEFAULT false,                    -- True = Client target/type/action değiştiremez (Sadece label/order/visibility değiştirebilir)

    custom_css_class varchar(100),                        -- Özel CSS sınıfı

    created_at timestamp NOT NULL DEFAULT now(),
    updated_at timestamp NOT NULL DEFAULT now()
);

COMMENT ON TABLE presentation.client_navigation IS 'Dynamic frontend navigation management. Can be derived from catalog templates.';
