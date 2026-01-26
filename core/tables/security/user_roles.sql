-- =============================================
-- Tablo: security.user_roles
-- Açıklama: Kullanıcı-tenant-rol ilişkilendirme tablosu
-- Bir kullanıcı farklı tenant'larda farklı rollere sahip olabilir
-- Örnek: Ali, TenantA'da SUPERADMIN, TenantB'de VIEWER olabilir
-- =============================================

DROP TABLE IF EXISTS security.user_roles CASCADE;

CREATE TABLE security.user_roles (
    user_id BIGINT NOT NULL,                               -- Kullanıcı ID (FK: security.users)
    tenant_id BIGINT NOT NULL,                             -- Tenant ID (FK: core.tenants)
    role_id BIGINT NOT NULL,                               -- Rol ID (FK: security.tenant_roles)
    PRIMARY KEY (user_id, tenant_id, role_id)              -- Composite primary key
);

COMMENT ON TABLE security.user_roles IS 'User-tenant-role mapping table allowing users to have different roles across different tenants';
