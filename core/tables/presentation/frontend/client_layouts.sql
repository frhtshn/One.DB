-- =============================================
-- Tenant Layouts (Sayfa Yerleşimleri)
-- Hangi sayfada, hangi pozisyonda, hangi widget var?
-- =============================================

DROP TABLE IF EXISTS presentation.tenant_layouts CASCADE;

CREATE TABLE presentation.tenant_layouts (
    id bigserial PRIMARY KEY,

    tenant_id bigint NOT NULL,                    -- Hangi tenant

    -- Kapsam
    page_id bigint,                               -- Spesifik sayfa için mi? (NULL = Global/Varsayılan)
    layout_name varchar(50) DEFAULT 'default',    -- Layout adı (home, game_detail, dashboard)

    -- Yerleşim Tanımı (JSON Structure for Performance)
    -- İlişkisel tablo yerine JSONB tercih edildi çünkü FE render için tek seferde tüm structure lazım.
    structure jsonb NOT NULL DEFAULT '[]',
    -- [
    --   {
    --     "position": "header_top",
    --     "widgets": [
    --       {"widget_code": "logo", "order": 1, "props": {...}},
    --       {"widget_code": "menu", "order": 2, "props": {...}},
    --       {"widget_code": "login_btn", "order": 3}
    --     ]
    --   },
    --   {
    --     "position": "main_content",
    --     "widgets": [...]
    --   }
    -- ]

    is_active boolean NOT NULL DEFAULT true,

    created_at timestamp NOT NULL DEFAULT now(),
    updated_at timestamp NOT NULL DEFAULT now()


);

COMMENT ON TABLE presentation.tenant_layouts IS 'Defines widget placements for tenant pages or global layouts';
