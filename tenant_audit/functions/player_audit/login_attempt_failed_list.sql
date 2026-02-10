-- ================================================================
-- LOGIN_ATTEMPT_FAILED_LIST: Oyuncu için başarısız giriş denemelerini getirir
-- Brute-force saldırı tespiti için kullanılır
-- Belirli süre içindeki başarısız denemeleri döner
-- ================================================================

DROP FUNCTION IF EXISTS player_audit.login_attempt_failed_list(BIGINT,INT);

CREATE OR REPLACE FUNCTION player_audit.login_attempt_failed_list(
    p_player_id BIGINT,          -- Player ID
    p_hours INT DEFAULT 1        -- Kaç saat geriye bakılsın
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
    v_since TIMESTAMPTZ;
BEGIN
    v_since := NOW() - (p_hours || ' hours')::INTERVAL;

    SELECT jsonb_build_object(
        'failedCount', COUNT(*),
        'since', v_since,
        'attempts', COALESCE(
            jsonb_agg(
                jsonb_build_object(
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
                    'failureReason', a.failure_reason,
                    'attemptedAt', a.attempted_at
                )
                ORDER BY a.attempted_at DESC
            ),
            '[]'::JSONB
        )
    ) INTO v_result
    FROM player_audit.login_attempts a
    WHERE a.player_id = p_player_id
      AND a.is_successful = FALSE
      AND a.attempted_at >= v_since;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION player_audit.login_attempt_failed_list IS 'Gets failed login attempts for a player for brute-force detection with full GeoIP data';
