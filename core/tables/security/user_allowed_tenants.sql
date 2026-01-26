-- =============================================
-- Tablo: security.user_allowed_tenants
-- Açıklama: Platform Rol Tenant Kısıtlaması
-- Platform kullanıcılarının hangi tenantlara erişebileceğini belirler
-- =============================================

DROP TABLE IF EXISTS security.user_allowed_tenants CASCADE;

CREATE TABLE security.user_allowed_tenants (
    user_id BIGINT NOT NULL REFERENCES security.users(id) ON DELETE CASCADE, -- Kullanıcı ID
    tenant_id BIGINT NOT NULL REFERENCES core.tenants(id) ON DELETE CASCADE, -- Tenant ID
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),         -- Oluşturulma zamanı
    created_by BIGINT REFERENCES security.users(id),       -- Oluşturan kullanıcı

    PRIMARY KEY (user_id, tenant_id)
);

COMMENT ON TABLE security.user_allowed_tenants IS 'Restricts platform users to specific tenants. Empty means access to all (superadmin mode).';
