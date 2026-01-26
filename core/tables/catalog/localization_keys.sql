-- =============================================
-- Tablo: catalog.localization_keys
-- Açıklama: Lokalizasyon anahtar kataloğu
-- Tüm çeviri anahtarlarının merkezi kaydı
-- Örnek: bo.menu.players, site.button.login
-- =============================================

DROP TABLE IF EXISTS catalog.localization_keys CASCADE;

CREATE TABLE catalog.localization_keys (
    id bigserial PRIMARY KEY,                              -- Benzersiz anahtar kimliği
    localization_key varchar(150) NOT NULL,                -- Çeviri anahtarı: bo.menu.players
    domain varchar(50) NOT NULL,                           -- Alan: BO (backoffice), SITE (frontend)
    category varchar(30) NOT NULL,                         -- Kategori: MENU, BUTTON, LABEL, MESSAGE
    description varchar(255),                              -- Anahtar açıklaması
    created_at timestamp without time zone NOT NULL DEFAULT now() -- Kayıt oluşturma zamanı
);
