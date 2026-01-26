-- =============================================
-- Tablo: billing.provider_commission_rates
-- Açıklama: Provider komisyon plan tanımları
-- Her provider için ürün bazında komisyon planı
-- Sabit oran veya kademeli (tiered) yapı olabilir
-- =============================================

DROP TABLE IF EXISTS billing.provider_commission_rates CASCADE;

CREATE TABLE billing.provider_commission_rates (
    id bigserial PRIMARY KEY,                              -- Benzersiz komisyon kimliği
    provider_code varchar(50) NOT NULL,                    -- Provider kodu: EGT, PRAGMATIC, NETENT
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

    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    updated_at timestamp without time zone NOT NULL DEFAULT now()  -- Son güncelleme zamanı
);
