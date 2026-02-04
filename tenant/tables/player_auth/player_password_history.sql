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
    changed_at timestamp without time zone NOT NULL DEFAULT now(), -- Değişiklik zamanı

    CONSTRAINT fk_player_password_history_player
        FOREIGN KEY (player_id) REFERENCES auth.players(id) ON DELETE CASCADE
);

-- Son şifreleri hızlı çekmek için index (player_id + changed_at DESC)
CREATE INDEX ix_player_password_history_lookup
    ON auth.player_password_history(player_id, changed_at DESC);

COMMENT ON TABLE auth.player_password_history IS 'Player password change history for preventing reuse of recent passwords';
