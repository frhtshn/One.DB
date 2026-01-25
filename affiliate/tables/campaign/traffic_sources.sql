DROP TABLE IF EXISTS core.traffic_sources CASCADE;

-- Trafik kaynakları tanımları
-- Oyuncuların hangi kanaldan geldiğini belirler
CREATE TABLE core.traffic_sources (
    id smallint PRIMARY KEY,
    code varchar(30) NOT NULL UNIQUE,      -- ORGANIC / AFFILIATE / PAID_ADS / SOCIAL / REFERRAL
    description varchar(100)
);
