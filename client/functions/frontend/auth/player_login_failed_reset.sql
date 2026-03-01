-- ================================================================
-- PLAYER_LOGIN_FAILED_RESET: Başarısız giriş sayacı sıfırla
-- ================================================================
-- Başarılı giriş sonrası sayacı sıfırlar.
-- Kilit bilgilerini temizler ve son giriş zamanını günceller.
-- ================================================================

DROP FUNCTION IF EXISTS auth.player_login_failed_reset(BIGINT);

CREATE OR REPLACE FUNCTION auth.player_login_failed_reset(
    p_player_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-auth.player-required';
    END IF;

    UPDATE auth.players
    SET access_failed_count = 0,
        lockout_enabled = FALSE,
        lockout_end_at = NULL,
        last_login_at = NOW(),
        updated_at = NOW()
    WHERE id = p_player_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.player-auth.player-not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION auth.player_login_failed_reset IS 'Resets failed login counter, clears lockout and updates last login timestamp on successful login.';
