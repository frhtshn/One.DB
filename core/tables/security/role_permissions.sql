-- =============================================
-- Tablo: security.role_permissions
-- Açıklama: Rol-yetki ilişkilendirme tablosu (M:N)
-- Hangi rolün hangi yetkilere sahip olduğunu belirler
-- =============================================

DROP TABLE IF EXISTS security.role_permissions CASCADE;

CREATE TABLE security.role_permissions (
    id BIGSERIAL PRIMARY KEY,                              -- Kayıt ID
    role_id BIGINT NOT NULL REFERENCES security.roles(id) ON DELETE CASCADE, -- Rol ID
    permission_id BIGINT NOT NULL REFERENCES security.permissions(id) ON DELETE CASCADE, -- Yetki ID
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),         -- Oluşturulma zamanı

    CONSTRAINT uq_role_permissions UNIQUE (role_id, permission_id)
);

COMMENT ON TABLE security.role_permissions IS 'Role-permission mapping table defining which permissions are granted to each role';
