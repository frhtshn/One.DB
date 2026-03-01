-- ================================================================
-- PLAYER_GET_PASSWORD_HASH: Oyuncu mevcut şifre hash'ini döner
-- ================================================================
-- Şifre değiştirme öncesi mevcut şifrenin doğrulanmasında kullanılır.
-- Player bulunamazsa NULL döner.
-- Pattern: player_change_password referans.
-- ================================================================

DROP FUNCTION IF EXISTS auth.player_get_password_hash(BIGINT);

CREATE OR REPLACE FUNCTION auth.player_get_password_hash(
    p_player_id BIGINT
)
RETURNS VARCHAR
LANGUAGE plpgsql
AS $$
DECLARE
    v_hash VARCHAR(255);
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-password.player-required';
    END IF;

    SELECT password INTO v_hash
    FROM auth.players
    WHERE id = p_player_id;

    RETURN v_hash;
END;
$$;

COMMENT ON FUNCTION auth.player_get_password_hash IS 'Returns current password hash for a player. Returns NULL if player not found. Used for current password verification before password change.';
