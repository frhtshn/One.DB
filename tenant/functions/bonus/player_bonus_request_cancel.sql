-- ================================================================
-- PLAYER_BONUS_REQUEST_CANCEL: Oyuncunun kendi talebini iptal et
-- ================================================================
-- Oyuncu sadece kendi pending talebini iptal edebilir.
-- Atanmış veya inceleme başlamış talepler iptal edilemez.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS bonus.player_bonus_request_cancel(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION bonus.player_bonus_request_cancel(
    p_player_id  BIGINT,
    p_request_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_request RECORD;
BEGIN
    -- Talep kontrolü
    SELECT player_id, status
    INTO v_request
    FROM bonus.bonus_requests
    WHERE id = p_request_id;

    IF v_request IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.bonus-request.not-found';
    END IF;

    -- Sahiplik kontrolü
    IF v_request.player_id <> p_player_id THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.bonus-request.not-owner';
    END IF;

    -- Sadece pending iptal edilebilir
    IF v_request.status <> 'pending' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-request.invalid-status';
    END IF;

    -- İptal et
    PERFORM bonus.bonus_request_cancel(
        p_request_id        := p_request_id,
        p_cancelled_by_id   := p_player_id,
        p_cancelled_by_type := 'PLAYER',
        p_note              := NULL
    );
END;
$$;

COMMENT ON FUNCTION bonus.player_bonus_request_cancel IS 'Allows a player to cancel their own pending bonus request. Only pending status is cancellable by the player.';
