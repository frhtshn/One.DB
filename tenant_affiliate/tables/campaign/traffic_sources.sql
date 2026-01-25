DROP TABLE IF EXISTS campaign.traffic_sources CASCADE;

-- Trafik kaynak tanımları
-- Affiliate sistemi için trafik kaynak tiplerini tutar
CREATE TABLE campaign.traffic_sources (
    id smallint PRIMARY KEY,
    code varchar(30) NOT NULL UNIQUE,      -- ORGANIC / AFFILIATE / PAID_ADS / SOCIAL / REFERRAL
    description varchar(100)
);
