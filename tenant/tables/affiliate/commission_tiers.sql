DROP TABLE IF EXISTS affiliate.commission_tiers CASCADE;

-- Komisyon kademeleri (10k %20 / 20k %25 / 30k %30 gibi)
-- Plana göre performans bazlı komisyon oranlarını tanımlar
CREATE TABLE affiliate.commission_tiers (
    id bigserial PRIMARY KEY,
    commission_plan_id bigint NOT NULL,     -- Komisyon planı referansı
    metric varchar(30) NOT NULL,            -- NGR / GGR / DEPOSIT
    range_from numeric(18,2) NOT NULL,      -- Alt limit
    range_to numeric(18,2),                 -- Üst limit (NULL = sınırsız)
    rate numeric(5,2) NOT NULL,             -- Yüzde oranı
    created_at timestamp without time zone NOT NULL DEFAULT now()
);
