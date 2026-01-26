-- =============================================
-- Tablo: security.role_permissions
-- Açıklama: Rol-yetki ilişkilendirme tablosu
-- Her rolün hangi yetkilere sahip olduğunu belirler
-- Many-to-many ilişki: Bir rol birden fazla yetkiye sahip olabilir
-- =============================================

DROP TABLE IF EXISTS security.role_permissions CASCADE;

CREATE TABLE security.role_permissions (
    role_id BIGINT NOT NULL,                               -- Rol ID (FK: security.tenant_roles)
    permission_code VARCHAR(100) NOT NULL,                 -- Yetki kodu (FK: security.permissions)
    PRIMARY KEY (role_id, permission_code)                 -- Composite primary key
);

COMMENT ON TABLE security.role_permissions IS 'Role-permission mapping table defining which permissions are granted to each role';
