-- ================================================================
-- TENANT_CRYPTOCURRENCY_MAPPING_LIST: Tüm aktif tenant'ların crypto eşlemelerini döner
-- CryptoRateSyncGrain tarafından çağrılır (system grain, yetki kontrolü yok)
-- Hangi tenant'lara hangi kripto kurlarının yazılacağını belirler
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_cryptocurrency_mapping_list();

CREATE OR REPLACE FUNCTION core.tenant_cryptocurrency_mapping_list()
RETURNS TABLE(
    tenant_id BIGINT,
    symbol    VARCHAR(20)
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        t.id AS tenant_id,
        tc.symbol
    FROM core.tenants t
    INNER JOIN core.tenant_cryptocurrencies tc ON tc.tenant_id = t.id
    WHERE t.status = 1
      AND tc.is_enabled = TRUE
    ORDER BY t.id, tc.symbol;
$$;

COMMENT ON FUNCTION core.tenant_cryptocurrency_mapping_list IS 'Lists all active tenant-cryptocurrency mappings for CryptoRateSyncGrain batch processing';
