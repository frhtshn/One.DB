DROP TABLE IF EXISTS campaign.attribution_models CASCADE;

-- Attribution (Atıf) Modelleri
-- Kampanyaların hangi modele göre takip edileceğini belirler
CREATE TABLE campaign.attribution_models (
    id smallint PRIMARY KEY,
    code varchar(30) UNIQUE,                -- FIRST_CLICK / LAST_CLICK / LINEAR / TIME_DECAY
    description varchar(100)
);
