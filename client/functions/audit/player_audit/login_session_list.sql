-- ================================================================
-- LOGIN_SESSION_LIST: Oyuncunun oturumlarını listeler
-- Aktif ve geçmiş oturumları GeoIP bilgisi ile döner
-- ================================================================

DROP FUNCTION IF EXISTS player_audit.login_session_list(BIGINT,BOOLEAN,INT);

CREATE OR REPLACE FUNCTION player_audit.login_session_list(
    p_player_id BIGINT,                      -- Player ID
    p_active_only BOOLEAN DEFAULT FALSE,     -- Sadece aktif oturumlar mı?
    p_limit INT DEFAULT 50                   -- Kayıt limiti
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
                'id', s.id,
                'sessionToken', s.session_token,
                'playerId', s.player_id,
                'ipAddress', s.ip_address::TEXT,
                'userAgent', s.user_agent,
                'deviceFingerprint', s.device_fingerprint,
                'country', s.country,
                'countryCode', s.country_code,
                'continent', s.continent,
                'continentCode', s.continent_code,
                'region', s.region,
                'regionName', s.region_name,
                'city', s.city,
                'district', s.district,
                'zip', s.zip,
                'lat', s.lat,
                'lon', s.lon,
                'timezone', s.timezone,
                'utcOffset', s.utc_offset,
                'currency', s.currency,
                'isp', s.isp,
                'org', s.org,
                'asNumber', s.as_number,
                'asName', s.as_name,
                'reverseDns', s.reverse_dns,
                'isMobile', s.is_mobile,
                'isProxy', s.is_proxy,
                'isHosting', s.is_hosting,
                'loginAt', s.login_at,
                'lastActivityAt', s.last_activity_at,
                'logoutAt', s.logout_at,
                'logoutType', s.logout_type,
                'isActive', s.is_active
            )
            ORDER BY s.login_at DESC
        ),
        '[]'::JSONB
    ) INTO v_result
    FROM player_audit.login_sessions s
    WHERE s.player_id = p_player_id
      AND (NOT p_active_only OR s.is_active = TRUE)
    LIMIT p_limit;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION player_audit.login_session_list IS 'Lists player sessions with full GeoIP data. Can filter active-only.';
