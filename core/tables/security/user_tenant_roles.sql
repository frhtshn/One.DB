-- =============================================
-- Tablo: security.user_tenant_roles
-- Açıklama: Tenant Bazlı Roller
-- Kullanıcının belirli bir tenant üzerindeki rolleri
-- =============================================

DROP TABLE IF EXISTS security.user_tenant_roles CASCADE;

CREATE TABLE security.user_tenant_roles (
    id BIGSERIAL PRIMARY KEY,                              -- Kayıt ID
    user_id BIGINT NOT NULL REFERENCES security.users(id) ON DELETE CASCADE, -- Kullanıcı ID
    tenant_id BIGINT NOT NULL,                             -- Tenant ID
    role_id BIGINT NOT NULL REFERENCES security.roles(id) ON DELETE CASCADE, -- Rol ID
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),        -- Atanma zamanı
    assigned_by BIGINT,                                    -- Atayan kullanıcı

    CONSTRAINT uq_user_tenant_roles UNIQUE (user_id, tenant_id, role_id)
);

COMMENT ON TABLE security.user_tenant_roles IS 'Tenant specific user roles mapping';
