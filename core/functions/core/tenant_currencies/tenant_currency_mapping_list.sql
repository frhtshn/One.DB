-- ================================================================
-- TENANT_CURRENCY_MAPPING_LIST: Tum aktif tenant'larin currency eslemelerini doner
-- CurrencyRateSyncGrain tarafindan cagrilir (system grain, yetki kontrolu yok)
-- Base currency'ye gore gruplama icin kullanilir
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_currency_mapping_list();

CREATE OR REPLACE FUNCTION core.tenant_currency_mapping_list()
RETURNS TABLE(
    tenant_id     BIGINT,
    base_currency CHAR(3),
    currency_code CHAR(3)
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        t.id AS tenant_id,
        t.base_currency,
        tc.currency_code
    FROM core.tenants t
    INNER JOIN core.tenant_currencies tc ON tc.tenant_id = t.id
    WHERE t.status = 1
      AND t.base_currency IS NOT NULL
      AND tc.is_enabled = TRUE
    ORDER BY t.id, tc.currency_code;
$$;

COMMENT ON FUNCTION core.tenant_currency_mapping_list IS 'Lists all active tenant-currency mappings for CurrencyRateSyncGrain batch processing';
