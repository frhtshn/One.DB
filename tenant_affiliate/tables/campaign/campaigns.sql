-- =============================================
-- Tablo: campaign.campaigns
-- Açıklama: Affiliate kampanya tanımları
-- Affiliate veya reklam kampanyalarının merkezi kaydı
-- Trafik takibi ve komisyon hesaplaması için kullanılır
-- =============================================

DROP TABLE IF EXISTS campaign.campaigns CASCADE;

CREATE TABLE campaign.campaigns (
    id bigserial PRIMARY KEY,                              -- Benzersiz kampanya kimliği
    traffic_source_id smallint NOT NULL,                   -- Trafik kaynağı ID (FK: campaign.traffic_sources)
    name varchar(100) NOT NULL,                            -- Kampanya adı
    start_date date,                                       -- Başlangıç tarihi
    end_date date,                                         -- Bitiş tarihi (NULL = süresiz)
    status smallint NOT NULL                               -- Durum: 0=Pasif, 1=Aktif, 2=Tamamlandı
);
