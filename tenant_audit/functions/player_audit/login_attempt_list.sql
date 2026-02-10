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
                'country', a.country,
                'countryCode', a.country_code,
                'continent', a.continent,
                'continentCode', a.continent_code,
                'region', a.region,
                'regionName', a.region_name,
                'city', a.city,
                'district', a.district,
                'zip', a.zip,
                'lat', a.lat,
                'lon', a.lon,
                'timezone', a.timezone,
                'utcOffset', a.utc_offset,
                'currency', a.currency,
                'isp', a.isp,
                'org', a.org,
                'asNumber', a.as_number,
                'asName', a.as_name,
                'reverseDns', a.reverse_dns,
                'isMobile', a.is_mobile,
                'isProxy', a.is_proxy,
                'isHosting', a.is_hosting,
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

COMMENT ON FUNCTION player_audit.login_attempt_list IS 'Lists login attempts for a player as JSONB array with full GeoIP data';
