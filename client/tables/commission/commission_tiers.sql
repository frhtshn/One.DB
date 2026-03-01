-- =============================================
-- Tablo: commission.commission_tiers
-- Açıklama: Komisyon kademe tanımları
-- Plana göre artan oranlı komisyon yapısı
-- Örnek: 10K=%20, 20K=%25, 30K=%30
-- GGR veya NGR bazlı tier yapısı
-- =============================================

DROP TABLE IF EXISTS commission.commission_tiers CASCADE;

CREATE TABLE commission.commission_tiers (
    id bigserial PRIMARY KEY,                              -- Benzersiz kademe kimliği
    commission_plan_id bigint NOT NULL,                    -- Plan ID (FK: commission.commission_plans)
    tier_type varchar(20) NOT NULL DEFAULT 'REVSHARE',     -- Kademe tipi: REVSHARE, CPA
    metric varchar(30) NOT NULL,                           -- Ölçüm metriki: NGR, GGR, DEPOSIT, TURNOVER, FTD_COUNT
    range_from numeric(18,2) NOT NULL,                     -- Alt limit (dahil)
    range_to numeric(18,2),                                -- Üst limit (NULL = sınırsız)
    rate numeric(5,2) NOT NULL,                            -- RevShare: yüzde oranı, CPA: sabit tutar
    rate_type varchar(10) NOT NULL DEFAULT 'PERCENT',      -- PERCENT veya FIXED
    currency varchar(20),                                   -- Sabit tutar için para birimi (Fiat: TRY, Crypto: BTC)
    is_active boolean NOT NULL DEFAULT true,               -- Kademe aktif mi?
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone
);

COMMENT ON TABLE commission.commission_tiers IS 'Progressive commission tier structures based on NGR, GGR, deposit, turnover or FTD count metrics';
COMMENT ON COLUMN commission.commission_tiers.tier_type IS 'REVSHARE for percentage-based, CPA for fixed amount per action';
COMMENT ON COLUMN commission.commission_tiers.rate_type IS 'PERCENT for percentage rates, FIXED for fixed currency amounts';

-- =============================================
-- Örnek Tier Yapıları:
--
-- NGR BAZLI REVSHARE (Standart):
-- | metric | range_from | range_to | rate | rate_type |
-- |--------|------------|----------|------|-----------|
-- | NGR    | 0          | 10000    | 25   | PERCENT   |
-- | NGR    | 10000      | 25000    | 30   | PERCENT   |
-- | NGR    | 25000      | 50000    | 35   | PERCENT   |
-- | NGR    | 50000      | NULL     | 40   | PERCENT   |
--
-- GGR BAZLI REVSHARE (Premium):
-- | metric | range_from | range_to | rate | rate_type |
-- |--------|------------|----------|------|-----------|
-- | GGR    | 0          | 20000    | 20   | PERCENT   |
-- | GGR    | 20000      | 50000    | 25   | PERCENT   |
-- | GGR    | 50000      | NULL     | 30   | PERCENT   |
--
-- CPA BAZLI (FTD Sayısına Göre):
-- | metric    | range_from | range_to | rate | rate_type |
-- |-----------|------------|----------|------|-----------|
-- | FTD_COUNT | 0          | 10       | 30   | FIXED     | → $30/FTD
-- | FTD_COUNT | 10         | 50       | 40   | FIXED     | → $40/FTD
-- | FTD_COUNT | 50         | NULL     | 50   | FIXED     | → $50/FTD
-- =============================================
