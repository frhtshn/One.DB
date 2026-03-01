-- ================================================================
-- CLIENT_CURRENCY_MAPPING_LIST: Tum aktif client'larin currency eslemelerini doner
-- CurrencyRateSyncGrain tarafindan cagrilir (system grain, yetki kontrolu yok)
-- Base currency'ye gore gruplama icin kullanilir
-- ================================================================

DROP FUNCTION IF EXISTS core.client_currency_mapping_list();

CREATE OR REPLACE FUNCTION core.client_currency_mapping_list()
RETURNS TABLE(
    client_id     BIGINT,
    base_currency CHAR(3),
    currency_code CHAR(3)
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        t.id AS client_id,
        t.base_currency,
        tc.currency_code
    FROM core.clients t
    INNER JOIN core.client_currencies tc ON tc.client_id = t.id
    WHERE t.status = 1
      AND t.base_currency IS NOT NULL
      AND tc.is_enabled = TRUE
    ORDER BY t.id, tc.currency_code;
$$;

COMMENT ON FUNCTION core.client_currency_mapping_list IS 'Lists all active client-currency mappings for CurrencyRateSyncGrain batch processing';
