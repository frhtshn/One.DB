-- ================================================================
-- PLAYER_UPDATE_STATUS: Oyuncu durumu güncelle
-- ================================================================
-- BO operatörü oyuncu durumunu değiştirir.
-- Session sonlandırma (suspend/close) backend sorumluluğundadır.
-- Backend tenant_audit DB'de login_session_end_all() çağırır.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS auth.player_update_status(BIGINT, SMALLINT, VARCHAR);

CREATE OR REPLACE FUNCTION auth.player_update_status(
    p_player_id  BIGINT,
    p_new_status SMALLINT,
    p_reason     VARCHAR(255) DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_status SMALLINT;
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player.player-required';
    END IF;

    -- Geçerli durum kontrolü (0-3)
    IF p_new_status IS NULL OR p_new_status NOT IN (0, 1, 2, 3) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player.invalid-status';
    END IF;

    -- Oyuncu kontrolü
    SELECT status INTO v_current_status
    FROM auth.players
    WHERE id = p_player_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.player.not-found';
    END IF;

    -- Aynı duruma güncelleme kontrolü
    IF v_current_status = p_new_status THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player.status-unchanged';
    END IF;

    -- Durumu güncelle
    UPDATE auth.players
    SET status = p_new_status,
        updated_at = NOW()
    WHERE id = p_player_id;
END;
$$;

COMMENT ON FUNCTION auth.player_update_status IS 'Updates player status (0=Pending, 1=Active, 2=Suspended, 3=Closed). Session termination on suspend/close is backend responsibility.';
