-- ================================================================
-- PLAYER_RESEND_VERIFICATION: Email doğrulama token yenileme
-- ================================================================
-- Mevcut kullanılmamış token'ları iptal eder.
-- Yeni doğrulama token'ı oluşturur.
-- Oyuncu zaten doğrulanmışsa hata verir.
-- ================================================================

DROP FUNCTION IF EXISTS auth.player_resend_verification(BIGINT, UUID, INT);

CREATE OR REPLACE FUNCTION auth.player_resend_verification(
    p_player_id             BIGINT,
    p_new_token             UUID,
    p_token_expires_minutes INT DEFAULT 1440
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-verify.player-required';
    END IF;

    IF p_new_token IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-verify.token-required';
    END IF;

    -- Oyuncu kontrolü + zaten doğrulanmış mı?
    IF NOT EXISTS (SELECT 1 FROM auth.players WHERE id = p_player_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.player-verify.player-not-found';
    END IF;

    IF EXISTS (SELECT 1 FROM auth.players WHERE id = p_player_id AND email_verified = TRUE) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.player-verify.already-verified';
    END IF;

    -- Mevcut kullanılmamış token'ları iptal et
    UPDATE auth.email_verification_tokens
    SET used_at = NOW()
    WHERE player_id = p_player_id
      AND used_at IS NULL;

    -- Yeni token oluştur
    INSERT INTO auth.email_verification_tokens (
        player_id, token, expires_at
    ) VALUES (
        p_player_id, p_new_token, NOW() + (p_token_expires_minutes || ' minutes')::INTERVAL
    );
END;
$$;

COMMENT ON FUNCTION auth.player_resend_verification IS 'Invalidates existing unused verification tokens and creates a new one. Fails if email already verified.';
