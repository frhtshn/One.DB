-- ================================================================
-- GAME_SESSION_CREATE: Oyun oturumu oluştur
-- ================================================================
-- Game launch sırasında çağrılır. Benzersiz session_token üretir.
-- Provider'a bu token iletilir, callback'lerde player çözümlemesi
-- için kullanılır. Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS game.game_session_create(BIGINT, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, INET, VARCHAR, VARCHAR, TEXT, INT);

CREATE OR REPLACE FUNCTION game.game_session_create(
    p_player_id BIGINT,
    p_provider_code VARCHAR(50),
    p_game_code VARCHAR(100),
    p_external_game_id VARCHAR(100) DEFAULT NULL,
    p_currency_code VARCHAR(20) DEFAULT NULL,
    p_mode VARCHAR(20) DEFAULT 'real',
    p_ip_address INET DEFAULT NULL,
    p_device_type VARCHAR(20) DEFAULT NULL,
    p_user_agent VARCHAR(500) DEFAULT NULL,
    p_metadata TEXT DEFAULT NULL,
    p_ttl_minutes INT DEFAULT 480
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_player_status SMALLINT;
    v_session_token VARCHAR(100);
    v_expires_at TIMESTAMPTZ;
    v_session_id BIGINT;
    v_metadata_json JSONB;
BEGIN
    -- Zorunlu alan kontrolleri
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.game.player-required';
    END IF;

    -- Player durum kontrolü
    SELECT status INTO v_player_status
    FROM auth.players
    WHERE id = p_player_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.wallet.player-not-found';
    END IF;

    IF v_player_status != 1 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.wallet.player-frozen';
    END IF;

    -- Token üret
    v_session_token := gen_random_uuid()::text;

    -- Son geçerlilik zamanı hesapla
    v_expires_at := NOW() + (p_ttl_minutes || ' minutes')::INTERVAL;

    -- Metadata parse
    v_metadata_json := CASE WHEN p_metadata IS NOT NULL THEN p_metadata::JSONB ELSE NULL END;

    -- Oturum oluştur
    INSERT INTO game.game_sessions (
        session_token, player_id, provider_code, game_code,
        external_game_id, currency_code, mode, status,
        ip_address, device_type, user_agent, metadata,
        created_at, expires_at
    ) VALUES (
        v_session_token, p_player_id, p_provider_code, p_game_code,
        p_external_game_id, p_currency_code, p_mode, 'active',
        p_ip_address, p_device_type, p_user_agent, v_metadata_json,
        NOW(), v_expires_at
    )
    RETURNING id INTO v_session_id;

    -- Sonuç dön
    RETURN jsonb_build_object(
        'sessionId', v_session_id,
        'sessionToken', v_session_token,
        'playerId', p_player_id,
        'gameCode', p_game_code,
        'currency', p_currency_code,
        'expiresAt', v_expires_at
    );
END;
$$;

COMMENT ON FUNCTION game.game_session_create IS 'Creates a game session with unique token for provider callback player resolution. Returns session details including token and expiry.';
