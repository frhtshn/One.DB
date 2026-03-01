-- ================================================================
-- PLAYER_IDENTITY_GET: Kimlik bilgilerini getir
-- ================================================================
-- Şifreli alanlar base64 olarak döner.
-- Kayıt yoksa NULL döner (hata değil — henüz girilmemiş olabilir).
-- ================================================================

DROP FUNCTION IF EXISTS profile.player_identity_get(BIGINT);

CREATE OR REPLACE FUNCTION profile.player_identity_get(
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
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-identity.player-required';
    END IF;

    SELECT jsonb_build_object(
        'id', pi.id,
        'playerId', pi.player_id,
        'identityNo', encode(pi.identity_no, 'base64'),
        'identityConfirmed', pi.identity_confirmed,
        'verifiedAt', pi.verified_at
    )
    INTO v_result
    FROM profile.player_identity pi
    WHERE pi.player_id = p_player_id;

    -- NULL döner, hata değil (kimlik henüz girilmemiş olabilir)
    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION profile.player_identity_get IS 'Returns player identity with encrypted fields as base64. Returns NULL if identity not submitted yet (not an error).';
