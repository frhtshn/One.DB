-- =============================================
-- Tablo: security.user_roles
-- Açıklama: Global Kullanıcı Rolleri
-- Kullanıcıların global (tenant bağımsız) rolleri
-- =============================================

DROP TABLE IF EXISTS security.user_roles CASCADE;

CREATE TABLE security.user_roles (
    id BIGSERIAL PRIMARY KEY,                              -- Kayıt ID
    user_id BIGINT NOT NULL,                               -- Kullanıcı ID (FK: security.users)
    role_id BIGINT NOT NULL,                               -- Rol ID (FK: security.roles)
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),        -- Atanma zamanı
    assigned_by BIGINT,                                    -- Atayan kullanıcı

    CONSTRAINT uq_user_roles UNIQUE (user_id, role_id)
);

COMMENT ON TABLE security.user_roles IS 'Global user roles mapping';
