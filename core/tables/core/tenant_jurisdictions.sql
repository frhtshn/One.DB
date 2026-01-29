-- =============================================
-- Tenant Jurisdictions (Tenant Lisansları)
-- Tenant'ın hangi jurisdiction'lar altında çalıştığı
-- Çoklu lisans desteği için M:N ilişki
-- =============================================

DROP TABLE IF EXISTS core.tenant_jurisdictions CASCADE;

CREATE TABLE core.tenant_jurisdictions (
    id bigserial PRIMARY KEY,

    tenant_id bigint NOT NULL,                    -- Hangi tenant
    jurisdiction_id int NOT NULL,                 -- Hangi lisans otoritesi

    -- Lisans detayları
    license_number varchar(100),                  -- Lisans numarası: MGA/B2C/123/2024
    license_issued_at date,                       -- Lisans verilme tarihi
    license_expires_at date,                      -- Lisans bitiş tarihi

    -- Öncelik ve durum
    is_primary boolean NOT NULL DEFAULT false,    -- Ana/varsayılan jurisdiction mu?
    status varchar(20) NOT NULL DEFAULT 'ACTIVE', -- Durumu
    -- ACTIVE: Aktif lisans
    -- PENDING: Başvuru sürecinde
    -- SUSPENDED: Askıya alınmış
    -- EXPIRED: Süresi dolmuş
    -- REVOKED: İptal edilmiş

    -- Özelleştirme (junction bazlı override'lar için)
    custom_settings jsonb,                        -- Tenant-specific jurisdiction ayarları

    created_at timestamp NOT NULL DEFAULT now(),
    updated_at timestamp NOT NULL DEFAULT now(),

    -- Aynı tenant-jurisdiction çifti bir kez olabilir
    UNIQUE(tenant_id, jurisdiction_id)
);

COMMENT ON TABLE core.tenant_jurisdictions IS 'Links tenants to their operating jurisdictions/licenses. Enables multi-license operations and jurisdiction-specific configurations.';
