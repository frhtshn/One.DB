-- =============================================
-- Tablo: security.user_allowed_tenants
-- Açıklama: Platform Rol Tenant Kısıtlaması
-- Platform kullanıcılarının hangi tenantlara erişebileceğini belirler
-- =============================================

DROP TABLE IF EXISTS security.user_allowed_tenants CASCADE;

CREATE TABLE security.user_allowed_tenants (
    user_id BIGINT NOT NULL,                               -- Kullanıcı ID (FK: security.users)
    tenant_id BIGINT NOT NULL,                             -- Tenant ID (FK: core.tenants)
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),         -- Oluşturulma zamanı
    created_by BIGINT,                                     -- Oluşturan kullanıcı (FK: security.users)

    PRIMARY KEY (user_id, tenant_id)
);

COMMENT ON TABLE security.user_allowed_tenants IS 'Restricts platform users to specific tenants. Empty means access to all (superadmin mode).';
