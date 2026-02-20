-- ================================================================
-- PLAYER_GET: BO oyuncu detay bilgisi
-- ================================================================
-- Tek oyuncunun kapsamlı bilgilerini döner.
-- Profil, kimlik, KYC, sınıflandırma, cüzdan ve kısıtlamalar.
-- Şifre hash'i dahil edilmez.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS auth.player_get(BIGINT);

CREATE OR REPLACE FUNCTION auth.player_get(
    p_player_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_player   RECORD;
    v_profile  JSONB;
    v_identity JSONB;
    v_kyc      JSONB;
    v_classification JSONB;
    v_wallets  JSONB;
    v_restrictions JSONB;
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player.player-required';
    END IF;

    -- Oyuncu temel bilgileri
    SELECT p.id, p.username, p.email_encrypted, p.status,
           p.email_verified, p.email_verified_at,
           p.two_factor_enabled, p.payment_two_factor_enabled,
           p.access_failed_count, p.lockout_enabled, p.lockout_end_at,
           p.last_password_change_at, p.require_password_change,
           p.registered_at, p.last_login_at, p.created_at, p.updated_at
    INTO v_player
    FROM auth.players p
    WHERE p.id = p_player_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.player.not-found';
    END IF;

    -- Profil bilgileri
    SELECT jsonb_build_object(
        'firstName', encode(pp.first_name, 'base64'),
        'middleName', encode(pp.middle_name, 'base64'),
        'lastName', encode(pp.last_name, 'base64'),
        'birthDate', pp.birth_date,
        'address', encode(pp.address, 'base64'),
        'phone', encode(pp.phone, 'base64'),
        'gsm', encode(pp.gsm, 'base64'),
        'countryCode', pp.country_code,
        'city', pp.city,
        'gender', pp.gender
    )
    INTO v_profile
    FROM profile.player_profile pp
    WHERE pp.player_id = p_player_id;

    -- Kimlik bilgileri
    SELECT jsonb_build_object(
        'identityNo', encode(pi.identity_no, 'base64'),
        'identityConfirmed', pi.identity_confirmed,
        'verifiedAt', pi.verified_at
    )
    INTO v_identity
    FROM profile.player_identity pi
    WHERE pi.player_id = p_player_id;

    -- KYC durumu (en son case)
    SELECT jsonb_build_object(
        'caseId', kc.id,
        'status', kc.current_status,
        'level', kc.kyc_level,
        'riskLevel', kc.risk_level,
        'reviewerId', kc.assigned_reviewer_id,
        'updatedAt', kc.updated_at
    )
    INTO v_kyc
    FROM kyc.player_kyc_cases kc
    WHERE kc.player_id = p_player_id
    ORDER BY kc.created_at DESC
    LIMIT 1;

    -- Sınıflandırma (kategori + gruplar)
    v_classification := auth.player_classification_list(p_player_id);

    -- Cüzdanlar
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'walletId', w.id,
            'walletType', w.wallet_type,
            'currencyCode', w.currency_code,
            'currencyType', w.currency_type,
            'balance', ws.balance,
            'isDefault', w.is_default,
            'status', w.status
        ) ORDER BY w.wallet_type, w.currency_code
    ), '[]'::jsonb)
    INTO v_wallets
    FROM wallet.wallets w
    LEFT JOIN wallet.wallet_snapshots ws ON ws.wallet_id = w.id
    WHERE w.player_id = p_player_id;

    -- Aktif kısıtlamalar
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', r.id,
            'restrictionType', r.restriction_type,
            'scope', r.scope,
            'status', r.status,
            'startsAt', r.starts_at,
            'endsAt', r.ends_at,
            'reason', r.reason,
            'setBy', r.set_by
        )
    ), '[]'::jsonb)
    INTO v_restrictions
    FROM kyc.player_restrictions r
    WHERE r.player_id = p_player_id
      AND r.status = 'active'
      AND (r.ends_at IS NULL OR r.ends_at > NOW());

    RETURN jsonb_build_object(
        'id', v_player.id,
        'username', v_player.username,
        'emailEncrypted', encode(v_player.email_encrypted, 'base64'),
        'status', v_player.status,
        'emailVerified', v_player.email_verified,
        'emailVerifiedAt', v_player.email_verified_at,
        'twoFactorEnabled', v_player.two_factor_enabled,
        'paymentTwoFactorEnabled', v_player.payment_two_factor_enabled,
        'accessFailedCount', v_player.access_failed_count,
        'lockoutEnabled', v_player.lockout_enabled,
        'lockoutEndAt', v_player.lockout_end_at,
        'lastPasswordChangeAt', v_player.last_password_change_at,
        'requirePasswordChange', v_player.require_password_change,
        'registeredAt', v_player.registered_at,
        'lastLoginAt', v_player.last_login_at,
        'profile', v_profile,
        'identity', v_identity,
        'kyc', v_kyc,
        'classification', v_classification,
        'wallets', v_wallets,
        'restrictions', v_restrictions
    );
END;
$$;

COMMENT ON FUNCTION auth.player_get IS 'Returns comprehensive player detail for backoffice. Includes profile, identity, KYC, classification, wallets and active restrictions. Password hash excluded.';
