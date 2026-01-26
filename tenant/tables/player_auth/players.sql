-- =============================================
-- Players (Oyuncu Ana Tablosu)
-- Oyuncu hesap bilgileri
-- Email şifreli saklanır (GDPR uyumlu)
-- =============================================

DROP TABLE IF EXISTS auth.players CASCADE;

CREATE TABLE auth.players (
    id bigserial PRIMARY KEY,
    username varchar(150) NOT NULL,               -- Kullanıcı adı (benzersiz olmalı)
    email_encrypted BYTEA NOT NULL,               -- Şifrelemiş email (AES-256)
    email_hash BYTEA NOT NULL,                    -- Email hash (arama için)
    status smallint NOT NULL DEFAULT 1,           -- Durum: 0=Pasif, 1=Aktif, 2=Askıya Alınmış, 3=Kapatılmış
    registered_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt tarihi
    last_login_at timestamp without time zone,    -- Son giriş tarihi
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);
