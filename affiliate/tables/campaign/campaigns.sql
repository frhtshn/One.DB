DROP TABLE IF EXISTS core.campaigns CASCADE;

-- Kampanya tanımları
-- Affiliate veya reklam kampanyalarının merkezi kaydı
CREATE TABLE core.campaigns (
    id bigserial PRIMARY KEY,
    tenant_id bigint NOT NULL,              -- Kampanyanın ait olduğu tenant
    traffic_source_id smallint NOT NULL,    -- Trafik kaynağı referansı
    name varchar(100) NOT NULL,             -- Kampanya adı
    start_date date,                        -- Başlangıç tarihi
    end_date date,                          -- Bitiş tarihi
    status smallint NOT NULL                -- 0: Pasif, 1: Aktif, 2: Tamamlandı
);
