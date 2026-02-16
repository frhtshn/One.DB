-- =============================================
-- Tablo: security.permission_template_items
-- Açıklama: Template'e bağlı permission öğeleri
-- Her template birden fazla permission içerebilir
-- =============================================

DROP TABLE IF EXISTS security.permission_template_items CASCADE;

CREATE TABLE security.permission_template_items (
    template_id BIGINT NOT NULL,                               -- Template ID (FK: security.permission_templates)
    permission_id BIGINT NOT NULL,                              -- Permission ID (FK: security.permissions)
    added_by BIGINT NOT NULL,                              -- Ekleyen kullanıcı ID
    added_at TIMESTAMPTZ DEFAULT NOW(),                    -- Eklenme zamanı
    PRIMARY KEY (template_id, permission_id)
);

COMMENT ON TABLE security.permission_template_items IS 'Permission items belonging to a template. Each item represents a permission that will be granted when the template is assigned';
