-- ================================================================
-- GAME_SESSION_END: Oyun oturumu kapat
-- ================================================================
-- Oyuncu çıkışı, provider kapanışı veya zorla kapatma durumunda
-- oturumu sonlandırır. İdempotent — zaten kapalı/expired oturum
-- için sessizce true döner. Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS game.game_session_end(VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION game.game_session_end(
    p_session_token VARCHAR(100),
    p_reason VARCHAR(50) DEFAULT 'PLAYER_LOGOUT'
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_affected INT;
BEGIN
    -- Aktif oturumu kapat
    UPDATE game.game_sessions SET
        status = 'closed',
        ended_at = NOW(),
        ended_reason = p_reason
    WHERE session_token = p_session_token
      AND status = 'active';

    GET DIAGNOSTICS v_affected = ROW_COUNT;

    -- Etkilenen satır olsun olmasın true dön (idempotent)
    RETURN true;
END;
$$;

COMMENT ON FUNCTION game.game_session_end IS 'Ends an active game session. Idempotent: returns true even if session is already closed or expired.';
