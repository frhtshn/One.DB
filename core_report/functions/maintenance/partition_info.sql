-- ================================================================
-- PARTITION_INFO: Mevcut partition durumunu raporlar
-- Performance, finance ve billing şemalarındaki tüm
-- partition'ların detaylı bilgisini döndürür.
-- ================================================================

DROP FUNCTION IF EXISTS maintenance.partition_info();

CREATE OR REPLACE FUNCTION maintenance.partition_info()
RETURNS TABLE (
    parent_schema TEXT,
    parent_table TEXT,
    partition_schema TEXT,
    partition_name TEXT,
    partition_expression TEXT,
    row_count BIGINT,
    total_size TEXT,
    is_default BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        nmsp_parent.nspname::TEXT   AS parent_schema,
        parent.relname::TEXT        AS parent_table,
        nmsp_child.nspname::TEXT    AS partition_schema,
        child.relname::TEXT         AS partition_name,
        pg_get_expr(child.relpartbound, child.oid)::TEXT AS partition_expression,
        child.reltuples::BIGINT     AS row_count,               -- Tahmini satır sayısı
        pg_size_pretty(pg_relation_size(child.oid))::TEXT AS total_size,  -- Disk boyutu
        child.relname ~ '_default$' AS is_default               -- Varsayılan partition mı
    FROM pg_inherits
    JOIN pg_class parent ON pg_inherits.inhparent = parent.oid
    JOIN pg_class child  ON pg_inherits.inhrelid  = child.oid
    JOIN pg_namespace nmsp_parent ON parent.relnamespace = nmsp_parent.oid
    JOIN pg_namespace nmsp_child  ON child.relnamespace  = nmsp_child.oid
    WHERE nmsp_parent.nspname IN ('performance', 'finance', 'billing')
    ORDER BY nmsp_parent.nspname, parent.relname, child.relname;
END;
$$;

COMMENT ON FUNCTION maintenance.partition_info IS 'Returns detailed information about all partitions in performance, finance and billing schemas including row counts, sizes and partition ranges.';
