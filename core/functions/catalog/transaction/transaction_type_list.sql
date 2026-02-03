-- ================================================================
-- TRANSACTION_TYPE_LIST: Transaction tipi dropdown için basit liste
-- Yetki kontrolü yok - Public catalog verisi
-- is_active response'da döner, filtreleme yok
-- ================================================================

DROP FUNCTION IF EXISTS catalog.transaction_type_list();

CREATE OR REPLACE FUNCTION catalog.transaction_type_list()
RETURNS TABLE(
    code VARCHAR(50),
    category VARCHAR(30),
    product VARCHAR(30),
    is_bonus BOOLEAN,
    is_free BOOLEAN,
    is_rollback BOOLEAN,
    is_winning BOOLEAN,
    is_reportable BOOLEAN,
    description TEXT,
    is_active BOOLEAN
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        tt.code,
        tt.category,
        tt.product,
        tt.is_bonus,
        tt.is_free,
        tt.is_rollback,
        tt.is_winning,
        tt.is_reportable,
        tt.description,
        tt.is_active
    FROM catalog.transaction_types tt
    ORDER BY tt.category, tt.code;
$$;

COMMENT ON FUNCTION catalog.transaction_type_list() IS 'Returns transaction type list for dropdowns. No auth required - public catalog data.';
