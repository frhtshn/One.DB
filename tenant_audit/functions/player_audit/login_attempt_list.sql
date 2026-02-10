-- ================================================================
-- LOGIN_ATTEMPT_LIST: Oyuncunun giriş denemelerini listeler
-- Güvenlik panelinde oyuncu detay sayfasında kullanılır
-- ================================================================

DROP FUNCTION IF EXISTS player_audit.login_attempt_list(BIGINT,INT);

CREATE OR REPLACE FUNCTION player_audit.login_attempt_list(
    p_player_id BIGINT,          -- Player ID
    p_limit INT DEFAULT 50       -- Kayıt limiti
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT COALESCE(
        jsonb_agg(
            jsonb_build_object(
                'id', a.id,
                'playerId', a.player_id,
                'identifier', a.identifier,
                'ipAddress', a.ip_address::TEXT,
                'userAgent', a.user_agent,
                'countryCode', a.country_code,
                'city', a.city,
                'isProxy', a.is_proxy,
                'isHosting', a.is_hosting,
                'isMobile', a.is_mobile,
                'isSuccessful', a.is_successful,
                'failureReason', a.failure_reason,
                'attemptedAt', a.attempted_at
            )
            ORDER BY a.attempted_at DESC
        ),
        '[]'::JSONB
    ) INTO v_result
    FROM player_audit.login_attempts a
    WHERE a.player_id = p_player_id
    LIMIT p_limit;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION player_audit.login_attempt_list IS 'Lists login attempts for a player as JSONB array with GeoIP data';
