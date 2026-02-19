-- ================================================================
-- PAYMENT_SESSION_CREATE: Ödeme oturumu oluştur
-- ================================================================
-- Deposit veya withdrawal başlatmadan önce çağrılır.
-- Benzersiz session_token üretir, TTL ile expire süresi belirler.
-- PSP callback'lerinde session takibi için kullanılır.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS transaction.payment_session_create(BIGINT, VARCHAR, DECIMAL, VARCHAR, BIGINT, DECIMAL, VARCHAR, INET, VARCHAR, VARCHAR, TEXT, INT);

CREATE OR REPLACE FUNCTION transaction.payment_session_create(
    p_player_id        BIGINT,
    p_session_type     VARCHAR(20),
    p_amount           DECIMAL(18,8),
    p_currency_code    VARCHAR(20),
    p_payment_method_id BIGINT DEFAULT NULL,
    p_fee_amount       DECIMAL(18,8) DEFAULT 0,
    p_idempotency_key  VARCHAR(100) DEFAULT NULL,
    p_ip_address       INET DEFAULT NULL,
    p_device_type      VARCHAR(20) DEFAULT NULL,
    p_user_agent       VARCHAR(500) DEFAULT NULL,
    p_metadata         TEXT DEFAULT NULL,
    p_ttl_minutes      INT DEFAULT 30
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_player_status   SMALLINT;
    v_session_token   VARCHAR(100);
    v_expires_at      TIMESTAMPTZ;
    v_net_amount      DECIMAL(18,8);
    v_session_id      BIGINT;
    v_metadata_json   JSONB;
BEGIN
    -- Zorunlu alan kontrolleri
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.finance.session-player-required';
    END IF;

    IF p_session_type IS NULL OR p_session_type NOT IN ('DEPOSIT', 'WITHDRAWAL') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.finance.session-type-required';
    END IF;

    IF p_amount IS NULL OR p_amount <= 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.finance.session-amount-required';
    END IF;

    -- Player durum kontrolü
    SELECT status INTO v_player_status
    FROM auth.players
    WHERE id = p_player_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.deposit.wallet-not-found';
    END IF;

    IF v_player_status != 1 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.deposit.player-not-active';
    END IF;

    -- Token üret
    v_session_token := gen_random_uuid()::text;

    -- Son geçerlilik zamanı
    v_expires_at := NOW() + (p_ttl_minutes || ' minutes')::INTERVAL;

    -- Net amount hesapla
    v_net_amount := CASE
        WHEN p_session_type = 'WITHDRAWAL' THEN p_amount + COALESCE(p_fee_amount, 0)
        ELSE p_amount
    END;

    -- Metadata parse
    v_metadata_json := CASE WHEN p_metadata IS NOT NULL THEN p_metadata::JSONB ELSE NULL END;

    -- Oturum oluştur
    INSERT INTO transaction.payment_sessions (
        session_token, player_id, session_type, payment_method_id,
        amount, currency_code, fee_amount, net_amount, status,
        idempotency_key, ip_address, device_type, user_agent,
        metadata, created_at, updated_at, expires_at
    ) VALUES (
        v_session_token, p_player_id, p_session_type, p_payment_method_id,
        p_amount, p_currency_code, COALESCE(p_fee_amount, 0), v_net_amount, 'created',
        NULLIF(TRIM(p_idempotency_key), ''), p_ip_address, p_device_type, p_user_agent,
        v_metadata_json, NOW(), NOW(), v_expires_at
    )
    RETURNING id INTO v_session_id;

    -- Sonuç dön
    RETURN jsonb_build_object(
        'sessionId', v_session_id,
        'sessionToken', v_session_token,
        'playerId', p_player_id,
        'sessionType', p_session_type,
        'amount', p_amount,
        'currency', p_currency_code,
        'feeAmount', COALESCE(p_fee_amount, 0),
        'expiresAt', v_expires_at
    );
END;
$$;

COMMENT ON FUNCTION transaction.payment_session_create IS 'Creates a payment session with unique token for deposit or withdrawal flow. Returns session details including token and expiry.';
