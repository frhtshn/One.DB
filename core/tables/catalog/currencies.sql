-- =============================================
-- Tablo: catalog.currencies
-- Açıklama: Para birimi referans kataloğu
-- ISO 4217 standartlarına uygun para birimi kodlarını içerir
-- =============================================

DROP TABLE IF EXISTS catalog.currencies CASCADE;

CREATE TABLE catalog.currencies (
    currency_code CHAR(3) PRIMARY KEY,        -- ISO 4217 para birimi kodu (TRY, EUR, USD)
    currency_name VARCHAR(100) NOT NULL,      -- Para birimi tam adı (Turkish Lira)
    symbol VARCHAR(10),                        -- Para birimi sembolü (₺, €, $)
    numeric_code SMALLINT,                     -- ISO 4217 numerik kodu (949, 978, 840)
    is_active BOOLEAN NOT NULL DEFAULT true,   -- Aktif/pasif durumu
    created_at TIMESTAMP NOT NULL DEFAULT now() -- Kayıt oluşturma zamanı
);

