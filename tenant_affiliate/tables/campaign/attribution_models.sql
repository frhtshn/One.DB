-- =============================================
-- Tablo: campaign.attribution_models
-- Açıklama: Attribution (atıf) model tanımları
-- Kampanyaların hangi modele göre takip edileceğini belirler
-- Örnek: FIRST_CLICK, LAST_CLICK, LINEAR, TIME_DECAY
-- =============================================

DROP TABLE IF EXISTS campaign.attribution_models CASCADE;

CREATE TABLE campaign.attribution_models (
    id smallint PRIMARY KEY,                               -- Benzersiz model kimliği
    code varchar(30) UNIQUE,                               -- Model kodu: FIRST_CLICK, LAST_CLICK, LINEAR
    description varchar(100)                               -- Model açıklaması
);
