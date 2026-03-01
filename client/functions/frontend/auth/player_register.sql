-- ================================================================
-- PLAYER_REGISTER: Yeni oyuncu kaydı
-- ================================================================
-- Username ve email benzersizlik kontrolü yapar.
-- Players tablosuna status=0 (Beklemede) ile kayıt oluşturur.
-- Email doğrulama token'ı oluşturur.
-- Auth-agnostic: şifre hash'i backend'den gelir (Argon2id).
-- ================================================================

DROP FUNCTION IF EXISTS auth.player_register(VARCHAR, BYTEA, BYTEA, VARCHAR, UUID, INT, CHAR, CHAR, CHAR);

CREATE OR REPLACE FUNCTION auth.player_register(
    p_username              VARCHAR(150),
    p_email_encrypted       BYTEA,
    p_email_hash            BYTEA,
    p_password_hash         VARCHAR(255),
    p_verification_token    UUID,
    p_token_expires_minutes INT DEFAULT 1440,
    p_country_code              CHAR(2) DEFAULT NULL,
    p_registration_ip_country   CHAR(2) DEFAULT NULL,
    p_language                  CHAR(2) DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_player_id BIGINT;
    v_username  VARCHAR(150);
BEGIN
    -- Zorunlu alan kontrolleri
    IF p_username IS NULL OR TRIM(p_username) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-register.username-required';
    END IF;

    IF p_email_encrypted IS NULL OR p_email_hash IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-register.email-required';
    END IF;

    IF p_password_hash IS NULL OR TRIM(p_password_hash) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-register.password-required';
    END IF;

    IF p_verification_token IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-register.token-required';
    END IF;

    -- Username normalize
    v_username := LOWER(TRIM(p_username));

    -- Username benzersizlik kontrolü
    IF EXISTS (SELECT 1 FROM auth.players WHERE username = v_username) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.player-register.username-exists';
    END IF;

    -- Email benzersizlik kontrolü
    IF EXISTS (SELECT 1 FROM auth.players WHERE email_hash = p_email_hash) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.player-register.email-exists';
    END IF;

    -- Oyuncu kaydı oluştur (status=0: Beklemede)
    INSERT INTO auth.players (
        username, email_encrypted, email_hash, password,
        status, email_verified
    ) VALUES (
        v_username, p_email_encrypted, p_email_hash, p_password_hash,
        0, FALSE
    )
    RETURNING id INTO v_player_id;

    -- Jurisdiction kaydı oluştur
    IF p_country_code IS NOT NULL THEN
        PERFORM kyc.jurisdiction_create(v_player_id, p_country_code, p_registration_ip_country);
    END IF;

    -- Email doğrulama token'ı oluştur
    INSERT INTO auth.email_verification_tokens (
        player_id, token, expires_at
    ) VALUES (
        v_player_id, p_verification_token, NOW() + (p_token_expires_minutes || ' minutes')::INTERVAL
    );

    RETURN jsonb_build_object(
        'playerId', v_player_id,
        'username', v_username,
        'status', 0,
        'emailVerified', FALSE,
        'createdAt', NOW()
    );
END;
$$;

COMMENT ON FUNCTION auth.player_register IS 'Registers a new player with status=0 (pending). Creates email verification token. Password hash provided by backend (Argon2id).';
