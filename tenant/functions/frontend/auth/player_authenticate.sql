-- ================================================================
-- PLAYER_AUTHENTICATE: Oyuncu kimlik doğrulama
-- ================================================================
-- Email hash ile oyuncu bilgilerini döner.
-- Şifre doğrulaması backend'de yapılır (Argon2id).
-- Hesap durumu, KYC, profil ve kısıtlama bilgilerini içerir.
-- Backend accountPhase hesaplaması için gerekli tüm veriyi sağlar.
-- ================================================================

DROP FUNCTION IF EXISTS auth.player_authenticate(BYTEA);

CREATE OR REPLACE FUNCTION auth.player_authenticate(
    p_email_hash BYTEA
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_player       RECORD;
    v_kyc          RECORD;
    v_profile_exists BOOLEAN;
    v_restrictions JSONB;
BEGIN
    IF p_email_hash IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-auth.email-required';
    END IF;

    -- Oyuncu bilgilerini al
    SELECT p.id, p.username, p.email_encrypted, p.status,
           p.email_verified, p.registered_at, p.last_login_at,
           p.password, p.two_factor_enabled, p.access_failed_count,
           p.lockout_enabled, p.lockout_end_at,
           p.last_password_change_at, p.require_password_change
    INTO v_player
    FROM auth.players p
    WHERE p.email_hash = p_email_hash;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0401', MESSAGE = 'error.player-auth.invalid-credentials';
    END IF;

    -- Hesap kilidi kontrolü
    IF v_player.lockout_enabled = TRUE AND v_player.lockout_end_at > NOW() THEN
        RAISE EXCEPTION USING ERRCODE = 'P0423', MESSAGE = 'error.player-auth.account-locked';
    END IF;

    -- Hesap durumu kontrolü (askıya alınmış veya kapatılmış)
    IF v_player.status = 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.player-auth.account-suspended';
    END IF;

    IF v_player.status = 3 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.player-auth.account-closed';
    END IF;

    -- KYC durumu (en son case)
    SELECT kc.current_status, kc.kyc_level, kc.risk_level
    INTO v_kyc
    FROM kyc.player_kyc_cases kc
    WHERE kc.player_id = v_player.id
    ORDER BY kc.created_at DESC
    LIMIT 1;

    -- Profil var mı?
    SELECT EXISTS (
        SELECT 1 FROM profile.player_profile pp WHERE pp.player_id = v_player.id
    ) INTO v_profile_exists;

    -- Aktif kısıtlamalar
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', r.id,
            'restrictionType', r.restriction_type,
            'scope', r.scope,
            'startsAt', r.starts_at,
            'endsAt', r.ends_at,
            'reason', r.reason,
            'setBy', r.set_by
        )
    ), '[]'::jsonb)
    INTO v_restrictions
    FROM kyc.player_restrictions r
    WHERE r.player_id = v_player.id
      AND r.status = 'active'
      AND (r.ends_at IS NULL OR r.ends_at > NOW());

    RETURN jsonb_build_object(
        'player', jsonb_build_object(
            'id', v_player.id,
            'username', v_player.username,
            'emailEncrypted', encode(v_player.email_encrypted, 'base64'),
            'status', v_player.status,
            'emailVerified', v_player.email_verified,
            'registeredAt', v_player.registered_at,
            'lastLoginAt', v_player.last_login_at
        ),
        'credentials', jsonb_build_object(
            'passwordHash', v_player.password,
            'twoFactorEnabled', v_player.two_factor_enabled,
            'accessFailedCount', v_player.access_failed_count,
            'lockoutEnabled', v_player.lockout_enabled,
            'lockoutEndAt', v_player.lockout_end_at,
            'lastPasswordChangeAt', v_player.last_password_change_at,
            'requirePasswordChange', v_player.require_password_change
        ),
        'kyc', jsonb_build_object(
            'status', v_kyc.current_status,
            'level', v_kyc.kyc_level,
            'riskLevel', v_kyc.risk_level
        ),
        'profileExists', v_profile_exists,
        'activeRestrictions', v_restrictions
    );
END;
$$;

COMMENT ON FUNCTION auth.player_authenticate IS 'Returns comprehensive player data for authentication. Password verification is done by backend (Argon2id). Includes KYC status, profile existence and active restrictions.';
