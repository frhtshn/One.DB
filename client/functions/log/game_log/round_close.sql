-- ================================================================
-- ROUND_CLOSE: Round'u kapat
-- ================================================================
-- PP endRound callback'i için. Round durumunu 'closed' yapar,
-- ended_at ve duration_ms hesaplar. Bulunamazsa sessizce
-- başarılı döner (idempotent). Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS game_log.round_close(BIGINT, VARCHAR, VARCHAR, TEXT);

CREATE OR REPLACE FUNCTION game_log.round_close(
    p_player_id BIGINT,
    p_provider_code VARCHAR(50),
    p_external_round_id VARCHAR(100),
    p_round_detail TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_round_id BIGINT;
    v_round_created_at TIMESTAMP;
    v_round_started_at TIMESTAMPTZ;
    v_detail JSONB;
BEGIN
    -- Round'u bul
    SELECT id, created_at, started_at
    INTO v_round_id, v_round_created_at, v_round_started_at
    FROM game_log.game_rounds
    WHERE external_round_id = p_external_round_id
      AND player_id = p_player_id
      AND provider_code = p_provider_code
    ORDER BY created_at DESC
    LIMIT 1;

    -- Bulunamazsa sessizce başarılı dön
    IF v_round_id IS NULL THEN
        RETURN;
    END IF;

    -- Round detail parse
    v_detail := CASE WHEN p_round_detail IS NOT NULL THEN p_round_detail::JSONB ELSE NULL END;

    -- Round'u kapat
    UPDATE game_log.game_rounds SET
        round_status = 'closed',
        ended_at = NOW(),
        duration_ms = EXTRACT(EPOCH FROM (NOW() - v_round_started_at))::INTEGER * 1000,
        round_detail = COALESCE(v_detail, round_detail)
    WHERE id = v_round_id
      AND created_at = v_round_created_at
      AND round_status = 'open';
END;
$$;

COMMENT ON FUNCTION game_log.round_close IS 'Closes a game round. Used by PP endRound callback. Idempotent: silently succeeds if round not found or already closed.';
