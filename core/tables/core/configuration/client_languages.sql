-- =============================================
-- Tablo: core.client_languages
-- Açıklama: Client dil etkinleştirme tablosu
-- Her client'in hangi dilleri destekleyeceğini belirler
-- =============================================

DROP TABLE IF EXISTS core.client_languages CASCADE;

CREATE TABLE core.client_languages (
    id bigserial PRIMARY KEY,                              -- Benzersiz kayıt kimliği
    client_id bigint NOT NULL,                             -- Client ID (FK: core.clients)
    language_code character(2) NOT NULL,                   -- Dil kodu (FK: catalog.languages)
    is_enabled boolean NOT NULL DEFAULT true,              -- Aktif/pasif durumu
    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    updated_at timestamp without time zone NOT NULL DEFAULT now()  -- Son güncelleme zamanı
);

COMMENT ON TABLE core.client_languages IS 'Client language enablement table defining which languages are supported by each client';
