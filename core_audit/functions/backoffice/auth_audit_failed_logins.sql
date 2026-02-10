-- ================================================================
-- AUTH_AUDIT_FAILED_LOGINS: Kullanıcı için başarısız giriş denemelerini getirir
-- Bu fonksiyon, kaba kuvvet saldırılarını tespit etmek için kullanılır
-- GeoIP bilgileri ile zenginleştirilmiş
-- ================================================================

DROP FUNCTION IF EXISTS backoffice.auth_audit_failed_logins(BIGINT,INT);

CREATE OR REPLACE FUNCTION backoffice.auth_audit_failed_logins(
    p_user_id BIGINT,
    p_hours INT DEFAULT 1
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
                    'ipAddress', a.ip_address,
                    'userAgent', a.user_agent,
                    'countryCode', a.country_code,
                    'city', a.city,
                    'isProxy', a.is_proxy,
                    'isHosting', a.is_hosting,
                    'isMobile', a.is_mobile,
                    'errorMessage', a.error_message,
                    'createdAt', a.created_at
                )
                ORDER BY a.created_at DESC
            ),
            '[]'::JSONB
        )
    ) INTO v_result
    FROM backoffice.auth_audit_log a
    WHERE a.user_id = p_user_id
      AND a.event_type = 'LOGIN_FAILED'
      AND a.created_at >= v_since;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION backoffice.auth_audit_failed_logins IS 'Gets failed login attempts with GeoIP data for brute-force detection';
