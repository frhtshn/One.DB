-- ================================================================
-- AUTH_AUDIT_LIST_BY_TYPE: Olay türüne göre kimlik denetim loglarını getirir
-- Bu fonksiyon, belirli bir olay türüne ait kimlik denetim loglarını JSONB formatında döndürür
-- Partitioned tablo: tarih filtresi ile partition pruning aktif
-- ================================================================

DROP FUNCTION IF EXISTS backoffice.auth_audit_list_by_type(VARCHAR(50),TIMESTAMPTZ,TIMESTAMPTZ,INT);

CREATE OR REPLACE FUNCTION backoffice.auth_audit_list_by_type(
    p_event_type VARCHAR(50),
    p_from_date TIMESTAMPTZ DEFAULT NULL,
    p_to_date TIMESTAMPTZ DEFAULT NULL,
    p_limit INT DEFAULT 100
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
                'success', a.success,
                'errorMessage', a.error_message,
                'createdAt', a.created_at
            )
            ORDER BY a.created_at DESC
        ),
        '[]'::JSONB
    ) INTO v_result
    FROM backoffice.auth_audit_log a
    WHERE a.event_type = p_event_type
      AND (p_from_date IS NULL OR a.created_at >= p_from_date)
      AND (p_to_date IS NULL OR a.created_at <= p_to_date)
    LIMIT p_limit;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION backoffice.auth_audit_list_by_type IS 'Retrieves auth audit logs by event type as JSONB array with full GeoIP data';
