-- =============================================
-- Tablo: security.permission_templates
-- Açıklama: Permission template tanımları
-- Kullanıcılara toplu yetki atamak için şablon sistemi
-- Snapshot model: template güncellemesi mevcut atamaları etkilemez
-- =============================================

DROP TABLE IF EXISTS security.permission_templates CASCADE;

CREATE TABLE security.permission_templates (
    id BIGSERIAL PRIMARY KEY,                              -- Template ID
    code VARCHAR(100) NOT NULL,                            -- Template kodu (lowercase, hyphen)
    name VARCHAR(150) NOT NULL,                            -- Template adı
    description VARCHAR(500),                              -- Template açıklaması
    company_id BIGINT NULL,                                -- NULL=platform, değer=company özel
    is_active BOOLEAN DEFAULT TRUE,                        -- Aktif/Pasif toggle
    created_by BIGINT NOT NULL,                            -- Oluşturan kullanıcı ID
    created_at TIMESTAMPTZ DEFAULT NOW(),                  -- Oluşturulma zamanı
    updated_by BIGINT NULL,                                -- Güncelleyen kullanıcı ID
    updated_at TIMESTAMPTZ DEFAULT NOW(),                  -- Güncellenme zamanı
    deleted_at TIMESTAMPTZ NULL,                           -- Silinme zamanı (soft-delete, hard delete YASAK)
    deleted_by BIGINT NULL,                                -- Silen kullanıcı ID

    CONSTRAINT chk_permission_templates_code CHECK (code ~ '^[a-z][a-z0-9-]*$'),
    CONSTRAINT chk_deletion CHECK (deleted_at IS NULL OR deleted_by IS NOT NULL)
);

COMMENT ON TABLE security.permission_templates IS 'Permission template definitions for bulk permission assignment. Snapshot model: template updates do not affect existing assignments';
