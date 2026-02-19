-- ================================================================
-- PLAYER_INFO_GET: Oyuncu bilgisi getir
-- ================================================================
-- Hub88 /user/info endpoint'i için oyuncu temel bilgilerini döner.
-- Şifreli alanları (first_name, last_name vb.) İÇERMEZ — sadece
-- metadata seviyesi bilgi. Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS wallet.player_info_get(BIGINT);

CREATE OR REPLACE FUNCTION wallet.player_info_get(
    p_player_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'playerId', p.id,
        'username', p.username,
        'status', p.status,
        'countryCode', pp.country_code,
        'gender', pp.gender,
        'registeredAt', p.registered_at
    )
    INTO v_result
    FROM auth.players p
    LEFT JOIN profile.player_profile pp ON pp.player_id = p.id
    WHERE p.id = p_player_id;

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.wallet.player-not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION wallet.player_info_get IS 'Returns player metadata for provider user info endpoints. Does not include encrypted PII fields.';
