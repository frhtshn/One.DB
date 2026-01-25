DROP TABLE IF EXISTS core.campaigns CASCADE;

-- Affiliate veya reklam kampanyalarının merkezi kaydı
CREATE TABLE campaign.campaigns (
    traffic_source_id smallint NOT NULL,    -- Trafik kaynağı referansı
    name varchar(100) NOT NULL,             -- Kampanya adı
    start_date date,                        -- Başlangıç tarihi
    end_date date,                          -- Bitiş tarihi
    status smallint NOT NULL                -- 0: Pasif, 1: Aktif, 2: Tamamlandı
);
