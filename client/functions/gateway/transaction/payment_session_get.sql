-- ================================================================
-- PAYMENT_SESSION_GET: Ödeme oturumu sorgula
-- ================================================================
-- Session token ile oturum bilgisini döner.
-- Süresi dolmuş oturumları otomatik expire eder.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS transaction.payment_session_get(VARCHAR);

CREATE OR REPLACE FUNCTION transaction.payment_session_get(
    p_session_token VARCHAR(100)
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_session RECORD;
BEGIN
    -- Token ile oturum bul
    SELECT * INTO v_session
    FROM transaction.payment_sessions
    WHERE session_token = p_session_token;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.finance.session-not-found';
    END IF;

    -- Expire kontrolü: aktif durumdaysa ve süresi dolmuşsa
    IF v_session.status IN ('created', 'processing', 'redirected', 'pending_approval')
       AND v_session.expires_at < NOW() THEN
        UPDATE transaction.payment_sessions
        SET status = 'expired', updated_at = NOW()
        WHERE id = v_session.id;

        RAISE EXCEPTION USING ERRCODE = 'P0410', MESSAGE = 'error.finance.session-expired';
    END IF;

    -- Zaten expired olarak işaretlenmişse
    IF v_session.status = 'expired' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0410', MESSAGE = 'error.finance.session-expired';
    END IF;

    -- Sonuç dön
    RETURN jsonb_build_object(
        'sessionId',             v_session.id,
        'sessionToken',          v_session.session_token,
        'playerId',              v_session.player_id,
        'sessionType',           v_session.session_type,
        'paymentMethodId',       v_session.payment_method_id,
        'amount',                v_session.amount,
        'currencyCode',          v_session.currency_code,
        'feeAmount',             v_session.fee_amount,
        'netAmount',             v_session.net_amount,
        'status',                v_session.status,
        'idempotencyKey',        v_session.idempotency_key,
        'transactionId',         v_session.transaction_id,
        'providerTransactionId', v_session.provider_transaction_id,
        'providerRedirectUrl',   v_session.provider_redirect_url,
        'providerData',          v_session.provider_data,
        'ipAddress',             v_session.ip_address,
        'deviceType',            v_session.device_type,
        'metadata',              v_session.metadata,
        'createdAt',             v_session.created_at,
        'updatedAt',             v_session.updated_at,
        'expiresAt',             v_session.expires_at,
        'completedAt',           v_session.completed_at
    );
END;
$$;

COMMENT ON FUNCTION transaction.payment_session_get IS 'Retrieves payment session by token. Auto-expires sessions past their TTL. Returns full session details as JSONB.';
