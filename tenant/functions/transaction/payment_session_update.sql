-- ================================================================
-- PAYMENT_SESSION_UPDATE: Ödeme oturumu güncelle
-- ================================================================
-- COALESCE ile kısmi güncelleme. Sadece NULL olmayan
-- parametreler güncellenir. PSP callback sonrası status,
-- provider bilgileri ve transaction_id güncellenir.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS transaction.payment_session_update(VARCHAR, VARCHAR, VARCHAR, TEXT, TEXT, BIGINT);

CREATE OR REPLACE FUNCTION transaction.payment_session_update(
    p_session_token            VARCHAR(100),
    p_status                   VARCHAR(20) DEFAULT NULL,
    p_provider_transaction_id  VARCHAR(100) DEFAULT NULL,
    p_provider_redirect_url    TEXT DEFAULT NULL,
    p_provider_data            TEXT DEFAULT NULL,
    p_transaction_id           BIGINT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_session_id    BIGINT;
    v_provider_json JSONB;
BEGIN
    -- Token ile oturum bul
    SELECT id INTO v_session_id
    FROM transaction.payment_sessions
    WHERE session_token = p_session_token;

    IF v_session_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.finance.session-not-found';
    END IF;

    -- Provider data parse
    v_provider_json := CASE
        WHEN p_provider_data IS NOT NULL AND TRIM(p_provider_data) <> ''
        THEN p_provider_data::JSONB
        ELSE NULL
    END;

    -- COALESCE ile kısmi güncelleme
    UPDATE transaction.payment_sessions
    SET status                  = COALESCE(p_status, status),
        provider_transaction_id = COALESCE(p_provider_transaction_id, provider_transaction_id),
        provider_redirect_url   = COALESCE(p_provider_redirect_url, provider_redirect_url),
        provider_data           = COALESCE(v_provider_json, provider_data),
        transaction_id          = COALESCE(p_transaction_id, transaction_id),
        completed_at            = CASE WHEN p_status = 'completed' THEN NOW() ELSE completed_at END,
        updated_at              = NOW()
    WHERE id = v_session_id;
END;
$$;

COMMENT ON FUNCTION transaction.payment_session_update IS 'Partially updates payment session using COALESCE. Only non-null parameters are applied. Auto-sets completed_at when status becomes completed.';
