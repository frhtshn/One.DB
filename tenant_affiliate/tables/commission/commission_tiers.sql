-- =============================================
-- Tablo: commission.commission_tiers
-- Açıklama: Komisyon kademe tanımları
-- Plana göre artan oranlı komisyon yapısı
-- Örnek: 10K=%20, 20K=%25, 30K=%30
-- =============================================

DROP TABLE IF EXISTS commission.commission_tiers CASCADE;

CREATE TABLE commission.commission_tiers (
    id bigserial PRIMARY KEY,                              -- Benzersiz kademe kimliği
    commission_plan_id bigint NOT NULL,                    -- Plan ID (FK: commission.commission_plans)
    metric varchar(30) NOT NULL,                           -- Ölçüm metriki: NGR, GGR, DEPOSIT, TURNOVER
    range_from numeric(18,2) NOT NULL,                     -- Alt limit (dahil)
    range_to numeric(18,2),                                -- Üst limit (NULL = sınırsız)
    rate numeric(5,2) NOT NULL,                            -- Komisyon oranı (yüzde)
    created_at timestamp without time zone NOT NULL DEFAULT now() -- Kayıt oluşturma zamanı
);

COMMENT ON TABLE commission.commission_tiers IS 'Progressive commission tier structures based on NGR, GGR, deposit, or turnover metrics';
