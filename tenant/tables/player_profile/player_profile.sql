-- =============================================
-- Player Profile (Oyuncu Profil Bilgileri)
-- Kişisel veriler şifreli saklanır (GDPR/KVKK uyumlu)
-- Hash alanları arama için kullanılır
-- =============================================

DROP TABLE IF EXISTS profile.player_profile CASCADE;

CREATE TABLE profile.player_profile (
    id bigserial PRIMARY KEY,
    player_id bigint NOT NULL,                    -- Oyuncu ID
    first_name BYTEA,                             -- Ad (şifreli)
    first_name_hash BYTEA,                        -- Ad hash (arama için)
    middle_name BYTEA,                            -- İkinci ad (şifreli)
    last_name BYTEA,                              -- Soyad (şifreli)
    last_name_hash BYTEA,                         -- Soyad hash (arama için)
    birth_date BYTEA,                             -- Doğum tarihi (şifreli)
    address BYTEA,                                -- Adres (şifreli)
    phone BYTEA,                                  -- Telefon (şifreli)
    phone_hash BYTEA,                             -- Telefon hash (arama için)
    gsm BYTEA,                                    -- Cep telefonu (şifreli)
    gsm_hash BYTEA,                               -- GSM hash (arama için)
    country_code character(2),                    -- Ülke kodu: TR, DE, GB
    city varchar(100),                            -- Şehir
    gender smallint,                              -- Cinsiyet: 0=Belirtilmemiş, 1=Erkek, 2=Kadın
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);

COMMENT ON TABLE profile.player_profile IS 'Player personal information with encrypted PII fields for GDPR/KVKK compliance';
