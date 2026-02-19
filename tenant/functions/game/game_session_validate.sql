-- ================================================================
-- GAME_SESSION_VALIDATE: Oyun oturumu doğrula
-- ================================================================
-- Provider callback'lerinde token ile player çözümlemesi yapar.
-- Süresi dolmuş oturumları otomatik expire eder.
-- Her başarılı doğrulamada last_activity_at günceller.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS game.game_session_validate(VARCHAR);

CREATE OR REPLACE FUNCTION game.game_session_validate(
    p_session_token VARCHAR(100)
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_session RECORD;
BEGIN
    -- Oturumu bul
    SELECT id, player_id, provider_code, game_code, currency_code,
           mode, status, expires_at
    INTO v_session
    FROM game.game_sessions
    WHERE session_token = p_session_token;

    -- Bulunamazsa hata
    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.game.session-not-found';
    END IF;

    -- Zaten kapalı veya expired ise hata
    IF v_session.status != 'active' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.game.session-expired';
    END IF;

    -- Süre dolmuş mu kontrol et
    IF v_session.expires_at < NOW() THEN
        -- Otomatik expire et
        UPDATE game.game_sessions SET
            status = 'expired',
            ended_at = NOW(),
            ended_reason = 'TIMEOUT'
        WHERE id = v_session.id;

        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.game.session-expired';
    END IF;

    -- Son aktivite zamanını güncelle
    UPDATE game.game_sessions SET
        last_activity_at = NOW()
    WHERE id = v_session.id;

    -- Sonuç dön
    RETURN jsonb_build_object(
        'playerId', v_session.player_id,
        'providerCode', v_session.provider_code,
        'gameCode', v_session.game_code,
        'currencyCode', v_session.currency_code,
        'mode', v_session.mode
    );
END;
$$;

COMMENT ON FUNCTION game.game_session_validate IS 'Validates a game session token and resolves player identity. Auto-expires timed-out sessions. Updates last activity timestamp.';
