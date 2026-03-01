-- ================================================================
-- PLAYER_PROFILE_GET: Oyuncu profil bilgilerini getir
-- ================================================================
-- Şifreli alanlar base64 olarak döner.
-- Backend'de çözümlenir (AES-256 decrypt).
-- ================================================================

DROP FUNCTION IF EXISTS profile.player_profile_get(BIGINT);

CREATE OR REPLACE FUNCTION profile.player_profile_get(
    p_player_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-profile.player-required';
    END IF;

    SELECT jsonb_build_object(
        'id', pp.id,
        'playerId', pp.player_id,
        'firstName', encode(pp.first_name, 'base64'),
        'middleName', encode(pp.middle_name, 'base64'),
        'lastName', encode(pp.last_name, 'base64'),
        'birthDate', pp.birth_date,
        'address', encode(pp.address, 'base64'),
        'phone', encode(pp.phone, 'base64'),
        'gsm', encode(pp.gsm, 'base64'),
        'countryCode', pp.country_code,
        'city', pp.city,
        'gender', pp.gender,
        'createdAt', pp.created_at,
        'updatedAt', pp.updated_at
    )
    INTO v_result
    FROM profile.player_profile pp
    WHERE pp.player_id = p_player_id;

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.player-profile.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION profile.player_profile_get IS 'Returns player profile with encrypted fields as base64. Backend decrypts with AES-256.';
