-- ================================================================
-- PLAYER_GET_PASSWORD_HISTORY: Oyuncu şifre geçmişini döner
-- ================================================================
-- Son N şifre hash'ini JSONB array olarak döner.
-- Şifre değiştirme sırasında geçmiş şifre tekrarı kontrolünde kullanılır.
-- Pattern: player_change_password referans.
-- ================================================================

DROP FUNCTION IF EXISTS auth.player_get_password_history(BIGINT, INT);

CREATE OR REPLACE FUNCTION auth.player_get_password_history(
    p_player_id BIGINT,
    p_count     INT DEFAULT 3
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-password.player-required';
    END IF;

    SELECT COALESCE(
        jsonb_agg(
            jsonb_build_object('password_hash', password_hash)
            ORDER BY changed_at DESC
        ),
        '[]'::JSONB
    ) INTO v_result
    FROM (
        SELECT password_hash, changed_at
        FROM auth.player_password_history
        WHERE player_id = p_player_id
        ORDER BY changed_at DESC
        LIMIT p_count
    ) sub;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION auth.player_get_password_history IS 'Returns last N password hashes for a player as a JSONB array. Used for password history reuse validation during password change.';
