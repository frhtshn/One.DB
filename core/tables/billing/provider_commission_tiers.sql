-- =============================================
-- Tablo: billing.provider_commission_tiers
-- Açıklama: Provider kademeli komisyon oranları
-- GGR/NGR miktarına göre değişen kademeli oranlar
-- Örnek: 0-200K=%20, 200K-400K=%18, 400K+=%15
-- =============================================

DROP TABLE IF EXISTS billing.provider_commission_tiers CASCADE;

CREATE TABLE billing.provider_commission_tiers (
    id bigserial PRIMARY KEY,                              -- Benzersiz kademe kimliği
    provider_commission_rate_id bigint NOT NULL,           -- Komisyon planı ID (FK: billing.provider_commission_rates)

    -- Kademe aralığı
    tier_from numeric(18,2) NOT NULL,                      -- Alt limit (dahil): 0, 200000, 400000
    tier_to numeric(18,2),                                 -- Üst limit (hariç): 200000, 400000, NULL=sınırsız

    -- Oran
    rate numeric(5,2) NOT NULL,                            -- Bu kademe için komisyon oranı (%)

    -- Sıralama
    tier_order smallint NOT NULL,                          -- Kademe sırası (1, 2, 3...)

    created_at timestamp without time zone NOT NULL DEFAULT now() -- Kayıt oluşturma zamanı
);

-- Örnek veri açıklaması:
-- EGT için GGR bazlı kademeli komisyon:
-- tier_order=1: tier_from=0, tier_to=200000, rate=20.00 (ilk 200K EUR için %20)
-- tier_order=2: tier_from=200000, tier_to=400000, rate=18.00 (200K-400K arası %18)
-- tier_order=3: tier_from=400000, tier_to=NULL, rate=15.00 (400K üstü %15)
