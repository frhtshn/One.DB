-- =============================================
-- Tablo: billing.tenant_commission_rates
-- Açıklama: Tenant standart komisyon oranları
-- Nucleo'nun tenant'lardan alacağı standart oranlar
-- Her provider/ürün için varsayılan komisyon planı
-- Belirli tenant özel oranları: tenant_commission_plans
-- =============================================

DROP TABLE IF EXISTS billing.tenant_commission_rates CASCADE;

CREATE TABLE billing.tenant_commission_rates (
    id bigserial PRIMARY KEY,                              -- Benzersiz komisyon kimliği
    provider_id bigint NOT NULL,                           -- Provider ID (FK: catalog.providers)
    product_code varchar(30) NOT NULL,                     -- Ürün kodu: GAME, SPORTS, PAYMENT
    commission_type varchar(20) NOT NULL,                  -- Komisyon tipi: GGR, NGR, TURNOVER

    -- Oran yapısı
    rate_type varchar(10) NOT NULL DEFAULT 'FLAT',         -- Oran tipi: FLAT (sabit), TIERED (kademeli)
    flat_rate numeric(5,2),                                -- Sabit oran (rate_type=FLAT ise)

    -- Para birimi (kademeli hesaplama için)
    tier_currency character(3) DEFAULT 'EUR',              -- Kademe eşik para birimi (TRY, EUR, USD)

    -- Geçerlilik
    valid_from date NOT NULL,                              -- Geçerlilik başlangıç tarihi
    valid_to date,                                         -- Geçerlilik bitiş tarihi (NULL = süresiz)
    is_active boolean NOT NULL DEFAULT true,               -- Aktif/pasif durumu

    -- Açıklama
    description text,                                      -- Plan açıklaması

    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    updated_at timestamp without time zone NOT NULL DEFAULT now()  -- Son güncelleme zamanı
);

