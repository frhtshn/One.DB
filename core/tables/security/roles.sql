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
    status SMALLINT NOT NULL DEFAULT 1,                    -- Durum
    is_platform_role BOOLEAN NOT NULL DEFAULT FALSE,       -- Platform rolü mü? (True ise tenant bağımsız)
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),         -- Oluşturulma zamanı
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),         -- Güncellenme zamanı

    CONSTRAINT uq_roles_code UNIQUE (code)
);

COMMENT ON TABLE security.roles IS 'Role definitions for the system (e.g., Admin, Viewer, Support)';
