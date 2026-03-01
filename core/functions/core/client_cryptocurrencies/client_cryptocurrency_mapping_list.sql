-- ================================================================
-- CLIENT_CRYPTOCURRENCY_MAPPING_LIST: Tüm aktif client'ların crypto eşlemelerini döner
-- CryptoRateSyncGrain tarafından çağrılır (system grain, yetki kontrolü yok)
-- Hangi client'lara hangi kripto kurlarının yazılacağını belirler
-- ================================================================

DROP FUNCTION IF EXISTS core.client_cryptocurrency_mapping_list();

CREATE OR REPLACE FUNCTION core.client_cryptocurrency_mapping_list()
RETURNS TABLE(
    client_id BIGINT,
    symbol    VARCHAR(20)
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        t.id AS client_id,
        tc.symbol
    FROM core.clients t
    INNER JOIN core.client_cryptocurrencies tc ON tc.client_id = t.id
    WHERE t.status = 1
      AND tc.is_enabled = TRUE
    ORDER BY t.id, tc.symbol;
$$;

COMMENT ON FUNCTION core.client_cryptocurrency_mapping_list IS 'Lists all active client-cryptocurrency mappings for CryptoRateSyncGrain batch processing';
