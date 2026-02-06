-- ================================================================
-- PARTITION_INFO: Partition durumunu raporlar
-- core_log veritabanı için monitoring ve health check
-- Her partitioned tablo için özet bilgi döner
-- ================================================================

DROP FUNCTION IF EXISTS maintenance.partition_info();

CREATE OR REPLACE FUNCTION maintenance.partition_info()
RETURNS TABLE (
    parent_table TEXT,
    partition_count INT,
    oldest_partition TEXT,
    newest_partition TEXT,
    total_size TEXT,
    default_partition_size TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    WITH partitions AS (
        SELECT
            pn.nspname || '.' || pc.relname AS parent_tbl,
            cn.nspname || '.' || cc.relname AS child_tbl,
            cc.relname AS child_name,
            pg_total_relation_size(cc.oid) AS child_size,
            cc.relname LIKE '%_default' AS is_default
        FROM pg_inherits i
        JOIN pg_class pc ON pc.oid = i.inhparent
        JOIN pg_namespace pn ON pn.oid = pc.relnamespace
        JOIN pg_class cc ON cc.oid = i.inhrelid
        JOIN pg_namespace cn ON cn.oid = cc.relnamespace
        WHERE pn.nspname IN ('logs', 'backoffice')
    ),
    summary AS (
        SELECT
            p.parent_tbl,
            count(*) FILTER (WHERE NOT p.is_default) AS part_count,
            min(p.child_name) FILTER (WHERE NOT p.is_default) AS oldest_part,
            max(p.child_name) FILTER (WHERE NOT p.is_default) AS newest_part,
            pg_size_pretty(sum(p.child_size)) AS total_sz,
            pg_size_pretty(sum(p.child_size) FILTER (WHERE p.is_default)) AS default_sz
        FROM partitions p
        GROUP BY p.parent_tbl
    )
    SELECT
        s.parent_tbl::TEXT,
        s.part_count::INT,
        s.oldest_part::TEXT,
        s.newest_part::TEXT,
        s.total_sz::TEXT,
        COALESCE(s.default_sz, '0 bytes')::TEXT
    FROM summary s
    ORDER BY s.parent_tbl;
END;
$$;

COMMENT ON FUNCTION maintenance.partition_info() IS 'Reports partition status for all partitioned tables in core_log. Shows count, size, oldest/newest partitions.';
