-- ================================================================
-- PLAYER_VERIFY_EMAIL: Email doğrulama
-- ================================================================
-- Token ile email doğrulaması yapar.
-- Token geçerlilik ve süre kontrolü yapar.
-- Oyuncunun email_verified alanını günceller.
-- ================================================================

DROP FUNCTION IF EXISTS auth.player_verify_email(UUID);

CREATE OR REPLACE FUNCTION auth.player_verify_email(
    p_token UUID
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_token_record RECORD;
BEGIN
    IF p_token IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-verify.token-required';
    END IF;

    -- Token bul (kullanılmamış)
    SELECT t.id, t.player_id, t.expires_at
    INTO v_token_record
    FROM auth.email_verification_tokens t
    WHERE t.token = p_token
      AND t.used_at IS NULL;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.player-verify.token-not-found';
    END IF;

    -- Süre kontrolü
    IF v_token_record.expires_at < NOW() THEN
        RAISE EXCEPTION USING ERRCODE = 'P0410', MESSAGE = 'error.player-verify.token-expired';
    END IF;

    -- Zaten doğrulanmış mı?
    IF EXISTS (SELECT 1 FROM auth.players WHERE id = v_token_record.player_id AND email_verified = TRUE) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.player-verify.already-verified';
    END IF;

    -- Token'ı kullanıldı olarak işaretle
    UPDATE auth.email_verification_tokens
    SET used_at = NOW()
    WHERE id = v_token_record.id;

    -- Oyuncu email doğrulamasını güncelle
    UPDATE auth.players
    SET email_verified = TRUE,
        email_verified_at = NOW(),
        updated_at = NOW()
    WHERE id = v_token_record.player_id;

    RETURN jsonb_build_object(
        'playerId', v_token_record.player_id,
        'emailVerified', TRUE,
        'emailVerifiedAt', NOW()
    );
END;
$$;

COMMENT ON FUNCTION auth.player_verify_email IS 'Verifies player email using UUID token. Checks token validity and expiration. Updates player email_verified status.';
