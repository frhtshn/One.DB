-- =============================================
-- Navigation Template Items (Şablon Öğeleri)
-- Şablonlara ait standart menü öğeleri
-- =============================================

DROP TABLE IF EXISTS catalog.navigation_template_items CASCADE;

CREATE TABLE catalog.navigation_template_items (
    id bigserial PRIMARY KEY,
    template_id int NOT NULL,                             -- Hangi şablon

    menu_location varchar(50) NOT NULL,                   -- main_header, footer_col_1, sidebar

    -- Menü Metni (Default)
    translation_key varchar(100),                         -- menu.main.home
    default_label jsonb,                                  -- {"en": "Home", "tr": "Ana Sayfa"}

    icon varchar(50),

    -- Hedef (Master Data - Client değiştiremez)
    target_type varchar(20) NOT NULL DEFAULT 'internal',
    target_url varchar(255),
    target_action varchar(50),

    -- Hiyerarşi
    parent_id bigint,                                     -- Alt menü ise
    display_order int DEFAULT 0,

    -- Kurallar
    is_locked boolean DEFAULT true,                       -- Client bunu silebilir mi? (True = Silemez)
    is_mandatory boolean DEFAULT true,                    -- Client bunu gizleyebilir mi? (True = Gizleyemez)

    created_at timestamp NOT NULL DEFAULT now(),
    updated_at timestamp NOT NULL DEFAULT now()
);

COMMENT ON TABLE catalog.navigation_template_items IS 'Master navigation items defined in templates. Copied to client_navigation on setup.';
