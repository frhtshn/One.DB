-- =============================================
-- Tablo: affiliate.affiliates
-- Açıklama: Affiliate ana tanım tablosu
-- Sistemdeki tüm affiliate (ortaklık) hesapları
-- Her affiliate bir ticari varlığı temsil eder
-- =============================================

DROP TABLE IF EXISTS affiliate.affiliates CASCADE;

CREATE TABLE affiliate.affiliates (
    id bigserial PRIMARY KEY,                              -- Benzersiz affiliate kimliği
    code varchar(50) UNIQUE NOT NULL,                      -- Benzersiz affiliate kodu (referans için)
    name varchar(150) NOT NULL,                            -- Affiliate ticari adı/unvanı
    status smallint NOT NULL,                              -- Durum: 0=Pasif, 1=Aktif, 2=Askıda, 3=Kapatıldı
    created_at timestamp without time zone NOT NULL DEFAULT now() -- Kayıt oluşturma zamanı
);

COMMENT ON TABLE affiliate.affiliates IS 'Affiliate master table for partnership accounts representing commercial entities';
