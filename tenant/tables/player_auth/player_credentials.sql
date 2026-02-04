-- =============================================
-- Player Credentials (Şifre ve Güvenlik Bilgileri)
-- Oyuncu kimlik doğrulama verileri
-- Şifre Argon2d ile hash'lenir, 2FA anahtarları şifrelenir
-- =============================================

DROP TABLE IF EXISTS auth.player_credentials CASCADE;

CREATE TABLE auth.player_credentials (
    id bigserial PRIMARY KEY,
    player_id bigint NOT NULL,                    -- Oyuncu ID
    password VARCHAR(255) NOT NULL,               -- Argon2d hash (şifre + salt)
    two_factor_enabled BOOLEAN NOT NULL DEFAULT false,  -- 2FA aktif mi?
    two_factor_key BYTEA,                         -- 2FA gizli anahtarı (şifreli)
    payment_two_factor_enabled BOOLEAN NOT NULL DEFAULT false, -- Ödeme 2FA aktif mi?
    payment_two_factor_key BYTEA,                 -- Ödeme 2FA anahtarı (şifreli)
    access_failed_count integer NOT NULL DEFAULT 0,  -- Başarısız giriş sayısı
    lockout_enabled boolean NOT NULL DEFAULT false,  -- Hesap kilitli mi?
    lockout_end_at timestamp without time zone,   -- Kilit bitiş zamanı
    last_password_change_at timestamp without time zone, -- Son şifre değişikliği
    require_password_change boolean NOT NULL DEFAULT false, -- Zorunlu şifre değişikliği gerekiyor mu?
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);

COMMENT ON TABLE auth.player_credentials IS 'Player authentication credentials including Argon2d hashed passwords and 2FA secrets';
