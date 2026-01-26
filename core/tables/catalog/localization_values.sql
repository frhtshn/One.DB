-- =============================================
-- Tablo: catalog.localization_values
-- Açıklama: Lokalizasyon çeviri değerleri
-- Her anahtar için dil bazında çeviri metinleri
-- =============================================

DROP TABLE IF EXISTS catalog.localization_values CASCADE;

CREATE TABLE catalog.localization_values (
    id bigserial PRIMARY KEY,                              -- Benzersiz çeviri kimliği
    localization_key_id bigint NOT NULL,                   -- Anahtar ID (FK: catalog.localization_keys)
    language_code character(2) NOT NULL,                   -- Dil kodu (FK: catalog.languages)
    localized_text text NOT NULL,                          -- Çevrilmiş metin içeriği
    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    updated_at timestamp without time zone NOT NULL DEFAULT now()  -- Son güncelleme zamanı
);
