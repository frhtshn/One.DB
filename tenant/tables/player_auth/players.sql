-- =============================================
-- Players (Oyuncu Ana Tablosu)
-- Oyuncu hesap, kimlik doğrulama ve güvenlik bilgileri
-- Email şifreli saklanır (GDPR uyumlu)
-- Şifre Argon2d ile hash'lenir, 2FA anahtarları şifrelenir
-- =============================================

DROP TABLE IF EXISTS auth.players CASCADE;

CREATE TABLE auth.players (
    id bigserial PRIMARY KEY,
    username varchar(150) NOT NULL,               -- Kullanıcı adı (benzersiz olmalı)
    email_encrypted BYTEA NOT NULL,               -- Şifrelenmiş email (AES-256)
    email_hash BYTEA NOT NULL,                    -- Email hash (arama için)
    status smallint NOT NULL DEFAULT 1,           -- Durum: 0=Pasif, 1=Aktif, 2=Askıya Alınmış, 3=Kapatılmış
    -- Kimlik doğrulama alanları
    password VARCHAR(255) NOT NULL,               -- Argon2d hash (şifre + salt)
    two_factor_enabled BOOLEAN NOT NULL DEFAULT false,  -- 2FA aktif mi?
    two_factor_key BYTEA,                         -- 2FA gizli anahtarı (şifreli)
    payment_two_factor_enabled BOOLEAN NOT NULL DEFAULT false, -- Ödeme 2FA aktif mi?
    payment_two_factor_key BYTEA,                 -- Ödeme 2FA anahtarı (şifreli)
    -- Hesap güvenliği alanları
    access_failed_count integer NOT NULL DEFAULT 0,  -- Başarısız giriş sayısı
    lockout_enabled boolean NOT NULL DEFAULT false,  -- Hesap kilitli mi?
    lockout_end_at timestamp without time zone,   -- Kilit bitiş zamanı
    last_password_change_at timestamp without time zone, -- Son şifre değişikliği
    require_password_change boolean NOT NULL DEFAULT false, -- Zorunlu şifre değişikliği gerekiyor mu?
    -- Zaman damgaları
    registered_at timestamp without time zone NOT NULL DEFAULT now(),
    last_login_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);

COMMENT ON TABLE auth.players IS 'Player account master table with encrypted email, Argon2d hashed passwords and 2FA secrets';
