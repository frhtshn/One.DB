-- =============================================
-- Tenant Navigation (Site Menüleri)
-- Tenant'ın frontend navigasyon yönetimi
-- Header, Footer, Sidebar, Mobile Menu vb.
-- =============================================

DROP TABLE IF EXISTS presentation.tenant_navigation CASCADE;

CREATE TABLE presentation.tenant_navigation (
    id bigserial PRIMARY KEY,
    tenant_id bigint NOT NULL,                            -- Hangi tenant

    menu_location varchar(50) NOT NULL,                   -- Menü konumu: main_header, footer_col_1, sidebar, mobile_bottom

    -- Menü Metni (Hibrit Lokalizasyon)
    translation_key varchar(100),                         -- Sistem çevirisi için key: 'menu.main.home'
    custom_label jsonb,                                   -- Tenant override veya özel metin: {"en": "My Home", "tr": "Evim"}

    icon varchar(50),                                     -- İkon (fa-home, custom-icon)
    badge_text varchar(20),                               -- Badge (NEW, HOT)
    badge_color varchar(20),                              -- Badge rengi (#ff0000)

    -- Hedef (Link/Aksiyon)
    target_type varchar(20) NOT NULL DEFAULT 'INTERNAL',  -- INTERNAL, EXTERNAL, ACTION, ROUTE
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

    device_visibility varchar(20) DEFAULT 'ALL',          -- ALL, MOBILE_ONLY, DESKTOP_ONLY

    -- Sistem Koruması
    is_system boolean DEFAULT false,                      -- Sistem menüsü mü? (Değiştirilemez/Silinemez)
    is_editable boolean DEFAULT true,                     -- Düzenlenebilir mi?

    custom_css_class varchar(100),                        -- Özel CSS sınıfı

    created_at timestamp NOT NULL DEFAULT now(),
    updated_at timestamp NOT NULL DEFAULT now()
);

COMMENT ON TABLE presentation.tenant_navigation IS 'Dynamic frontend navigation management for tenants (Header, Footer, Mobile, etc.)';
