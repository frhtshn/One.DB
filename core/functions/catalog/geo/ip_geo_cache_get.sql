-- ================================================================
-- IP_GEO_CACHE_GET: Cache'den IP geo bilgisini getir
-- expires_at kontrolü yapar, süresi dolmuş kayıtlar NULL döner
-- Backend: NULL dönerse ip-api.com'u çağırmalı
-- ================================================================

DROP FUNCTION IF EXISTS catalog.ip_geo_cache_get(INET);

CREATE OR REPLACE FUNCTION catalog.ip_geo_cache_get(
    p_ip_address INET    -- Sorgulanacak IP adresi
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'ipAddress',      c.ip_address::TEXT,
        'country',        c.country,
        'countryCode',    c.country_code,
        'continent',      c.continent,
        'continentCode',  c.continent_code,
        'region',         c.region,
        'regionName',     c.region_name,
        'city',           c.city,
        'district',       c.district,
        'zip',            c.zip,
        'lat',            c.lat,
        'lon',            c.lon,
        'timezone',       c.timezone,
        'utcOffset',      c.utc_offset,
        'currency',       c.currency,
        'isp',            c.isp,
        'org',            c.org,
        'asNumber',       c.as_number,
        'asName',         c.as_name,
        'reverseDns',     c.reverse_dns,
        'isMobile',       c.is_mobile,
        'isProxy',        c.is_proxy,
        'isHosting',      c.is_hosting,
        'resolvedAt',     c.resolved_at,
        'expiresAt',      c.expires_at
    ) INTO v_result
    FROM catalog.ip_geo_cache c
    WHERE c.ip_address = p_ip_address
      AND c.expires_at > NOW();

    -- Süresi dolmuş veya kayıt yoksa NULL döner
    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION catalog.ip_geo_cache_get IS 'Retrieves cached IP geolocation data. Returns NULL if not found or expired.';
