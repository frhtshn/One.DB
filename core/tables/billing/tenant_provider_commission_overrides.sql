-- Tenant Provider Komisyon Override'ları
-- Belirli tenant'lar için özel komisyon oranları tanımlar
-- Ana komisyon oranını geçersiz kılar (override)

DROP TABLE IF EXISTS billing.tenant_provider_commission_overrides CASCADE;

CREATE TABLE billing.tenant_provider_commission_overrides (
    id bigserial PRIMARY KEY,
    tenant_id bigint NOT NULL,                      -- Tenant ID
    provider_commission_rate_id bigint NOT NULL,    -- Ana komisyon oranı referansı
    override_rate numeric(5,2) NOT NULL,            -- Özel komisyon oranı
    valid_from date NOT NULL,                       -- Geçerlilik başlangıç tarihi
    valid_to date                                   -- Geçerlilik bitiş tarihi (NULL = süresiz)
);
