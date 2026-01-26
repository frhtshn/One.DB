-- =============================================
-- Tablo: billing.tenant_commission_rate_tiers
-- Açıklama: Tenant standart komisyon kademeleri
-- Nucleo'nun tenant'lardan alacağı standart kademe tanımları
-- tenant_commission_rates.rate_type=TIERED ise kullanılır
-- Belirli tenant özel kademeleri: tenant_commission_plan_tiers
-- =============================================

DROP TABLE IF EXISTS billing.tenant_commission_rate_tiers CASCADE;

CREATE TABLE billing.tenant_commission_rate_tiers (
    id bigserial PRIMARY KEY,                              -- Benzersiz kademe kimliği
    rate_id bigint NOT NULL,                               -- Hangi komisyon oranına ait (tenant_commission_rates.id)

    -- Kademe tanımı
    tier_order smallint NOT NULL,                          -- Kademe sırası: 1, 2, 3...
    tier_name varchar(50),                                 -- Kademe adı: Bronze, Silver, Gold
    min_amount numeric(18,2) NOT NULL,                     -- Kademe alt sınırı (dahil)
    max_amount numeric(18,2),                              -- Kademe üst sınırı (dahil değil, NULL=sınırsız)

    -- Oran
    rate numeric(5,2) NOT NULL,                            -- Bu kademe için komisyon oranı (%)

    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    updated_at timestamp without time zone NOT NULL DEFAULT now()  -- Son güncelleme zamanı
);

