-- ================================================================
-- IP_GEO_CACHE_CLEANUP: Süresi dolmuş cache kayıtlarını temizle
-- Periyodik maintenance görevi olarak çalıştırılmalı
-- ================================================================

DROP FUNCTION IF EXISTS catalog.ip_geo_cache_cleanup(INT);

CREATE OR REPLACE FUNCTION catalog.ip_geo_cache_cleanup(
    p_expired_days INT DEFAULT 0    -- Ek gün toleransı (0 = tam expired olanlar)
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_deleted INT;
BEGIN
    DELETE FROM catalog.ip_geo_cache
    WHERE expires_at < NOW() - (p_expired_days || ' days')::INTERVAL;

    GET DIAGNOSTICS v_deleted = ROW_COUNT;

    RETURN v_deleted;
END;
$$;

COMMENT ON FUNCTION catalog.ip_geo_cache_cleanup IS 'Removes expired IP geolocation cache entries. Returns number of deleted rows.';
