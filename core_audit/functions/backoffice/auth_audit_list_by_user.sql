-- ================================================================
-- AUTH_AUDIT_LIST_BY_USER: Kullanıcıya göre kimlik denetim loglarını getirir
-- Bu fonksiyon, belirli bir kullanıcıya ait kimlik denetim loglarını JSONB formatında döndürür
-- ================================================================

DROP FUNCTION IF EXISTS backoffice.auth_audit_list_by_user(BIGINT,INT);

CREATE OR REPLACE FUNCTION backoffice.auth_audit_list_by_user(
    p_user_id BIGINT,
    p_limit INT DEFAULT 50
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
                'userId', a.user_id,
                'companyId', a.company_id,
                'tenantId', a.tenant_id,
                'eventType', a.event_type,
                'eventData', a.event_data,
                'ipAddress', a.ip_address,
                'userAgent', a.user_agent,
                'countryCode', a.country_code,
                'city', a.city,
                'isProxy', a.is_proxy,
                'isHosting', a.is_hosting,
                'isMobile', a.is_mobile,
                'success', a.success,
                'errorMessage', a.error_message,
                'createdAt', a.created_at
            )
            ORDER BY a.created_at DESC
        ),
        '[]'::JSONB
    ) INTO v_result
    FROM backoffice.auth_audit_log a
    WHERE a.user_id = p_user_id
    LIMIT p_limit;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION backoffice.auth_audit_list_by_user IS 'Retrieves auth audit logs for a user as JSONB array with GeoIP data';
