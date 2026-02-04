-- =============================================
-- Player Password History (Şifre Geçmişi)
-- Oyuncu şifre değişiklik geçmişi
-- Son N şifre saklanır, eski şifrelerle aynı şifre kullanımı engellenir
-- =============================================

DROP TABLE IF EXISTS auth.player_password_history CASCADE;

CREATE TABLE auth.player_password_history (
    id bigserial PRIMARY KEY,
    player_id bigint NOT NULL,                       -- Oyuncu ID
    password_hash varchar(255) NOT NULL,             -- Eski şifre hash'i (Argon2d)
    changed_at timestamp without time zone NOT NULL DEFAULT now() -- Değişiklik zamanı
);

COMMENT ON TABLE auth.player_password_history IS 'Player password change history for preventing reuse of recent passwords';
