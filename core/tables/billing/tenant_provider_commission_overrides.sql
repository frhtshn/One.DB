-- =============================================
-- Tablo: billing.tenant_provider_commission_overrides
-- Açıklama: Tenant özel komisyon oranları
-- Belirli tenant'lar için özel komisyon oranları tanımlar
-- Ana komisyon oranını geçersiz kılar (override)
-- =============================================

DROP TABLE IF EXISTS billing.tenant_provider_commission_overrides CASCADE;

CREATE TABLE billing.tenant_provider_commission_overrides (
    id bigserial PRIMARY KEY,                              -- Benzersiz override kimliği
    tenant_id bigint NOT NULL,                             -- Tenant ID (FK: core.tenants)
    provider_commission_rate_id bigint NOT NULL,           -- Ana komisyon oranı ID (FK: billing.provider_commission_rates)
    override_rate numeric(5,2) NOT NULL,                   -- Özel komisyon oranı
    valid_from date NOT NULL,                              -- Geçerlilik başlangıç tarihi
    valid_to date                                          -- Geçerlilik bitiş tarihi (NULL = süresiz)
);
