DROP TABLE IF EXISTS core.attribution_models CASCADE;

-- Atıf (attribution) modeli tanımları
-- Oyuncu kazanımının hangi affiliate'e atfedileceğini belirleyen kurallar
CREATE TABLE core.attribution_models (
    id smallint PRIMARY KEY,
    code varchar(30) UNIQUE,                -- FIRST_CLICK / LAST_CLICK / LINEAR / TIME_DECAY
    description varchar(100)
);
