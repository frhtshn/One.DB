-- =============================================
-- Tablo: security.tenant_roles
-- Açıklama: Tenant bazında rol tanımları
-- Her tenant kendi rollerini tanımlayabilir
-- Örnek: SUPERADMIN, EDITOR, VIEWER, FINANCE
-- =============================================

DROP TABLE IF EXISTS security.tenant_roles CASCADE;

CREATE TABLE security.tenant_roles (
    id BIGSERIAL PRIMARY KEY,                              -- Benzersiz rol kimliği
    tenant_id BIGINT NOT NULL,                             -- Tenant ID (FK: core.tenants)
    code VARCHAR(50) NOT NULL,                             -- Rol kodu: SUPERADMIN, EDITOR, VIEWER
    description VARCHAR(255),                              -- Rol açıklaması
    UNIQUE (tenant_id, code)                               -- Tenant başına benzersiz rol kodu
);
