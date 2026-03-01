-- =============================================
-- Tablo: security.user_roles
-- Açıklama: Birleşik Kullanıcı Rolleri
-- client_id = NULL: Global roller (platform seviyesi)
-- client_id = değer: Client-specific roller
-- =============================================

DROP TABLE IF EXISTS security.user_roles CASCADE;

CREATE TABLE security.user_roles (
    id BIGSERIAL PRIMARY KEY,                              -- Kayıt ID
    user_id BIGINT NOT NULL,                               -- Kullanıcı ID (FK: security.users)
    role_id BIGINT NOT NULL,                               -- Rol ID (FK: security.roles)
    client_id BIGINT NULL,                                 -- NULL = global rol, değer = client-specific rol
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),        -- Atanma zamanı
    assigned_by BIGINT                                     -- Atayan kullanıcı
);

COMMENT ON TABLE security.user_roles IS 'Unified user roles: client_id=NULL for global, client_id=value for client-specific';
COMMENT ON COLUMN security.user_roles.client_id IS 'NULL for global/platform roles, client ID for client-specific roles';
