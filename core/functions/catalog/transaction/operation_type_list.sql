-- ================================================================
-- OPERATION_TYPE_LIST: Operation tipi dropdown için basit liste
-- Yetki kontrolü yok - Public catalog verisi
-- is_active response'da döner, filtreleme yok
-- ================================================================

DROP FUNCTION IF EXISTS catalog.operation_type_list();

CREATE OR REPLACE FUNCTION catalog.operation_type_list()
RETURNS TABLE(
    code VARCHAR(30),
    wallet_effect SMALLINT,
    affects_balance BOOLEAN,
    affects_locked BOOLEAN,
    description TEXT,
    is_active BOOLEAN
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        ot.code,
        ot.wallet_effect,
        ot.affects_balance,
        ot.affects_locked,
        ot.description,
        ot.is_active
    FROM catalog.operation_types ot
    ORDER BY ot.code;
$$;

COMMENT ON FUNCTION catalog.operation_type_list() IS 'Returns operation type list for dropdowns. No auth required - public catalog data.';
