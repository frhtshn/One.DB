-- =============================================
-- Tablo: security.user_roles
-- Açıklama: Birleşik Kullanıcı Rolleri
-- tenant_id = NULL: Global roller (platform seviyesi)
-- tenant_id = değer: Tenant-specific roller
-- =============================================

DROP TABLE IF EXISTS security.user_roles CASCADE;

CREATE TABLE security.user_roles (
    id BIGSERIAL PRIMARY KEY,                              -- Kayıt ID
    user_id BIGINT NOT NULL,                               -- Kullanıcı ID (FK: security.users)
    role_id BIGINT NOT NULL,                               -- Rol ID (FK: security.roles)
    tenant_id BIGINT NULL,                                 -- NULL = global rol, değer = tenant-specific rol
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),        -- Atanma zamanı
    assigned_by BIGINT                                     -- Atayan kullanıcı
);

COMMENT ON TABLE security.user_roles IS 'Unified user roles: tenant_id=NULL for global, tenant_id=value for tenant-specific';
COMMENT ON COLUMN security.user_roles.tenant_id IS 'NULL for global/platform roles, tenant ID for tenant-specific roles';
