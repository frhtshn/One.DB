-- =============================================
-- Tablo: security.roles
-- Açıklama: Rol tanımları
-- Sistemdeki rollerin listesi (Admin, Viewer, Support vb.)
-- =============================================

DROP TABLE IF EXISTS security.roles CASCADE;

CREATE TABLE security.roles (
    id BIGSERIAL PRIMARY KEY,                              -- Rol ID
    code VARCHAR(50) NOT NULL,                             -- Rol kodu (admin, support vb.)
    name VARCHAR(100) NOT NULL,                            -- Rol adı
    description VARCHAR(500),                              -- Rol açıklaması
    level INT NOT NULL DEFAULT 0,                          -- Hiyerarşi seviyesi (yüksek = daha yetkili)
    status SMALLINT NOT NULL DEFAULT 1,                    -- Durum
    is_platform_role BOOLEAN NOT NULL DEFAULT FALSE,       -- Platform rolü mü? (True ise client bağımsız)
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),         -- Oluşturulma zamanı
    created_by BIGINT,                                     -- Oluşturan kullanıcı ID
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),         -- Güncellenme zamanı
    updated_by BIGINT,                                     -- Güncelleyen kullanıcı ID
    deleted_at TIMESTAMPTZ,                                -- Silinme zamanı (Soft delete)
    deleted_by BIGINT,                                     -- Silen kullanıcı ID

    CONSTRAINT uq_roles_code UNIQUE (code)
);

COMMENT ON TABLE security.roles IS 'Role definitions for the system (e.g., Admin, Viewer, Support)';
