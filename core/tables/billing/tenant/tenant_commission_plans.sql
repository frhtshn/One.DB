-- =============================================
-- Tablo: billing.tenant_commission_plans
-- Açıklama: Tenant özel komisyon planları
-- Her tenant için provider bazında özel komisyon yapısı
-- Provider varsayılan oranlarını geçersiz kılar (override)
-- Sabit oran veya kademeli yapı destekler
-- =============================================

DROP TABLE IF EXISTS billing.tenant_commission_plans CASCADE;

CREATE TABLE billing.tenant_commission_plans (
    id bigserial PRIMARY KEY,                              -- Benzersiz plan kimliği
    tenant_id bigint NOT NULL,                             -- Tenant ID (FK: core.tenants)
    provider_id bigint NOT NULL,                           -- Provider ID (FK: catalog.providers)
    product_code varchar(30) NOT NULL,                     -- Ürün kodu: GAME, SPORTS, PAYMENT
    commission_type varchar(20) NOT NULL,                  -- Komisyon tipi: GGR, NGR, TURNOVER

    -- Oran yapısı
    rate_type varchar(10) NOT NULL DEFAULT 'FLAT',         -- Oran tipi: FLAT (sabit), TIERED (kademeli)
    flat_rate numeric(5,2),                                -- Sabit oran (rate_type=FLAT ise)

    -- Para birimi (kademeli hesaplama için)
    tier_currency character(3) DEFAULT 'EUR',              -- Kademe eşik para birimi

    -- Geçerlilik
    valid_from date NOT NULL,                              -- Geçerlilik başlangıç tarihi
    valid_to date,                                         -- Geçerlilik bitiş tarihi (NULL = süresiz)
    is_active boolean NOT NULL DEFAULT true,               -- Aktif/pasif durumu

    -- Kaynak bilgisi
    source_rate_id bigint,                                 -- Baz alınan provider oranı (opsiyonel)

    created_by bigint,                                     -- Oluşturan kullanıcı ID (FK: security.users)
    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    updated_at timestamp without time zone NOT NULL DEFAULT now(), -- Son güncelleme zamanı

    -- Tenant + Provider + Product için tek aktif plan
    UNIQUE (tenant_id, provider_id, product_code, commission_type, valid_from)
);

COMMENT ON TABLE billing.tenant_commission_plans IS 'Custom tenant commission plans overriding default provider rates with flat or tiered structures';
