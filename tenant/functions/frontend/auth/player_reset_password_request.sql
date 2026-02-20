-- ================================================================
-- PLAYER_RESET_PASSWORD_REQUEST: Şifre sıfırlama talebi
-- ================================================================
-- Mevcut kullanılmamış token'ları iptal eder.
-- Yeni şifre sıfırlama token'ı oluşturur.
-- Backend email gönderimini yapar.
-- ================================================================

DROP FUNCTION IF EXISTS auth.player_reset_password_request(BIGINT, UUID, INT);

CREATE OR REPLACE FUNCTION auth.player_reset_password_request(
    p_player_id        BIGINT,
    p_token            UUID,
    p_expires_minutes  INT DEFAULT 60
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-password.player-required';
    END IF;

    IF p_token IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-password.token-required';
    END IF;

    -- Oyuncu kontrolü
    IF NOT EXISTS (SELECT 1 FROM auth.players WHERE id = p_player_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.player-password.player-not-found';
    END IF;

    -- Mevcut kullanılmamış token'ları iptal et
    UPDATE auth.password_reset_tokens
    SET used_at = NOW()
    WHERE player_id = p_player_id
      AND used_at IS NULL;

    -- Yeni token oluştur
    INSERT INTO auth.password_reset_tokens (
        player_id, token, expires_at
    ) VALUES (
        p_player_id, p_token, NOW() + (p_expires_minutes || ' minutes')::INTERVAL
    );
END;
$$;

COMMENT ON FUNCTION auth.player_reset_password_request IS 'Creates password reset token. Invalidates any existing unused tokens for the player.';
