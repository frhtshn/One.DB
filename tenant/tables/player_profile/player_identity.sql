-- =============================================
-- Player Identity (Kimlik Bilgileri)
-- TC Kimlik No / Pasaport No gibi kimlik verileri
-- Şifreli saklanır, doğrulama durumu tutulur
-- =============================================

DROP TABLE IF EXISTS profile.player_identity CASCADE;

CREATE TABLE profile.player_identity (
    id bigserial PRIMARY KEY,
    player_id bigint NOT NULL,                    -- Oyuncu ID
    identity_no BYTEA,                            -- TC Kimlik / Pasaport No (şifreli)
    identity_no_hash BYTEA,                       -- Kimlik No hash (arama için)
    identity_confirmed boolean NOT NULL DEFAULT false, -- Kimlik doğrulandı mı?
    verified_at timestamp without time zone       -- Doğrulama tarihi
);
