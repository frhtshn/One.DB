-- ================================================================
-- ROUND_CANCEL: Round'u iptal et
-- ================================================================
-- Provider tarafından round iptali veya full refund sonrası
-- çağrılır. Durumu 'cancelled' veya 'refunded' yapar.
-- Bulunamazsa sessizce başarılı döner (idempotent).
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS game_log.round_cancel(BIGINT, VARCHAR, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION game_log.round_cancel(
    p_player_id BIGINT,
    p_provider_code VARCHAR(50),
    p_external_round_id VARCHAR(100),
    p_status VARCHAR(20) DEFAULT 'cancelled'
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_round_id BIGINT;
    v_round_created_at TIMESTAMP;
BEGIN
    -- Round'u bul
    SELECT id, created_at
    INTO v_round_id, v_round_created_at
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

    -- Round durumunu güncelle
    UPDATE game_log.game_rounds SET
        round_status = p_status,
        ended_at = NOW()
    WHERE id = v_round_id
      AND created_at = v_round_created_at;
END;
$$;

COMMENT ON FUNCTION game_log.round_cancel IS 'Cancels or marks a game round as refunded. Idempotent: silently succeeds if round not found.';
