-- =============================================
-- Tablo: billing.client_commission_plan_tiers
-- Açıklama: Client özel plan kademeleri
-- Belirli client'lar için özel/override kademe tanımları
-- Standart kademeler: client_commission_rate_tiers
-- =============================================

DROP TABLE IF EXISTS billing.client_commission_plan_tiers CASCADE;

CREATE TABLE billing.client_commission_plan_tiers (
    id bigserial PRIMARY KEY,                              -- Benzersiz kademe kimliği
    client_commission_plan_id bigint NOT NULL,             -- Client komisyon planı ID (FK: billing.client_commission_plans)

    -- Kademe aralığı
    tier_from numeric(18,2) NOT NULL,                      -- Alt limit (dahil): 0, 200000, 400000
    tier_to numeric(18,2),                                 -- Üst limit (hariç): 200000, 400000, NULL=sınırsız

    -- Oran
    rate numeric(5,2) NOT NULL,                            -- Bu kademe için komisyon oranı (%)

    -- Sıralama
    tier_order smallint NOT NULL,                          -- Kademe sırası (1, 2, 3...)

    created_at timestamp without time zone NOT NULL DEFAULT now() -- Kayıt oluşturma zamanı
);

COMMENT ON TABLE billing.client_commission_plan_tiers IS 'Custom tier definitions for client-specific commission plans with override rate brackets';

-- Örnek senaryo:
-- ClientA için EGT özel anlaşma:
-- tier_order=1: tier_from=0, tier_to=150000, rate=18.00 (ilk 150K EUR için %18)
-- tier_order=2: tier_from=150000, tier_to=300000, rate=16.00 (150K-300K arası %16)
-- tier_order=3: tier_from=300000, tier_to=NULL, rate=14.00 (300K üstü %14)
