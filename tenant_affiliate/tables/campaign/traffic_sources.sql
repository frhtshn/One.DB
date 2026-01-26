-- =============================================
-- Tablo: campaign.traffic_sources
-- Açıklama: Trafik kaynak tanımları
-- Affiliate sistemi için trafik kaynak tiplerini tutar
-- Örnek: ORGANIC, AFFILIATE, PAID_ADS, SOCIAL, REFERRAL
-- =============================================

DROP TABLE IF EXISTS campaign.traffic_sources CASCADE;

CREATE TABLE campaign.traffic_sources (
    id smallint PRIMARY KEY,                               -- Benzersiz kaynak kimliği
    code varchar(30) NOT NULL UNIQUE,                      -- Kaynak kodu: ORGANIC, AFFILIATE, PAID_ADS
    description varchar(100)                               -- Kaynak açıklaması
);
