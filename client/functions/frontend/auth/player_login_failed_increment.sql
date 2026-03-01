-- ================================================================
-- PLAYER_LOGIN_FAILED_INCREMENT: Başarısız giriş sayacı artır
-- ================================================================
-- Başarısız giriş denemesinde sayacı artırır.
-- Eşik aşıldığında hesabı kilitler.
-- Pattern: core.user_login_failed_increment referans.
-- ================================================================

DROP FUNCTION IF EXISTS auth.player_login_failed_increment(BIGINT, INT, INT);

CREATE OR REPLACE FUNCTION auth.player_login_failed_increment(
    p_player_id           BIGINT,
    p_lock_threshold      INT DEFAULT 5,
    p_lock_duration_minutes INT DEFAULT 30
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_failed_count INT;
    v_is_locked    BOOLEAN := FALSE;
    v_locked_until TIMESTAMPTZ;
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-auth.player-required';
    END IF;

    -- Sayacı artır
    UPDATE auth.players
    SET access_failed_count = access_failed_count + 1,
        updated_at = NOW()
    WHERE id = p_player_id
    RETURNING access_failed_count INTO v_failed_count;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.player-auth.player-not-found';
    END IF;

    -- Eşik kontrolü — kilitlenmeli mi?
    IF v_failed_count >= p_lock_threshold THEN
        v_locked_until := NOW() + (p_lock_duration_minutes || ' minutes')::INTERVAL;
        v_is_locked := TRUE;

        UPDATE auth.players
        SET lockout_enabled = TRUE,
            lockout_end_at = v_locked_until,
            updated_at = NOW()
        WHERE id = p_player_id;
    END IF;

    RETURN jsonb_build_object(
        'failedCount', v_failed_count,
        'isLocked', v_is_locked,
        'lockedUntil', v_locked_until
    );
END;
$$;

COMMENT ON FUNCTION auth.player_login_failed_increment IS 'Increments failed login counter. Auto-locks account when threshold exceeded. Returns current state.';
