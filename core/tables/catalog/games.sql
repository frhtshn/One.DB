-- =============================================
-- Tablo: catalog.games
-- Açıklama: Oyun kataloğu
-- Tüm provider'lardan gelen oyunların merkezi listesi
-- Her oyun tek bir provider'a bağlıdır
-- =============================================

DROP TABLE IF EXISTS catalog.games CASCADE;

CREATE TABLE catalog.games (
    id bigserial PRIMARY KEY,                              -- Benzersiz oyun kimliği
    provider_id bigint NOT NULL,                           -- Oyun sağlayıcı ID (FK: catalog.providers)
    game_code varchar(100) NOT NULL,                       -- Provider'ın oyun kodu (pragmatic_sweet_bonanza)
    game_name varchar(255) NOT NULL,                       -- Oyun görünen adı (Sweet Bonanza)
    game_type varchar(50),                                 -- Oyun tipi: SLOT, LIVE, TABLE, CRASH
    is_active boolean NOT NULL DEFAULT true,               -- Aktif/pasif durumu
    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    updated_at timestamp without time zone NOT NULL DEFAULT now()  -- Son güncelleme zamanı
);
