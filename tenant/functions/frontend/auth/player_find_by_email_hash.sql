-- ================================================================
-- PLAYER_FIND_BY_EMAIL_HASH: Email hash ile oyuncu arama (hafif)
-- ================================================================
-- Sadece player_id ve status doner.
-- ResendVerification ve ForgotPassword gibi akislarda
-- player_authenticate yerine kullanilir (KYC, restrictions cekmeye gerek yok).
-- ================================================================

DROP FUNCTION IF EXISTS auth.player_find_by_email_hash(BYTEA);

CREATE OR REPLACE FUNCTION auth.player_find_by_email_hash(
    p_email_hash BYTEA
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_player_id BIGINT;
    v_status    SMALLINT;
BEGIN
    IF p_email_hash IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-auth.email-required';
    END IF;

    SELECT p.id, p.status
    INTO v_player_id, v_status
    FROM auth.players p
    WHERE p.email_hash = p_email_hash;

    IF NOT FOUND THEN
        RETURN NULL;
    END IF;

    RETURN jsonb_build_object(
        'playerId', v_player_id,
        'status', v_status
    );
END;
$$;

COMMENT ON FUNCTION auth.player_find_by_email_hash IS 'Lightweight player lookup by email hash. Returns only playerId and status. Used for resend-verification and forgot-password flows.';
