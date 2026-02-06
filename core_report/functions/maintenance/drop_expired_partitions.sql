-- ================================================================
-- DROP_EXPIRED_PARTITIONS: Süresi dolmuş partition'ları siler
-- Varsayılan saklama süresi 36500 gün (yaklaşık 100 yıl).
-- İş verisi olduğu için pratikte silme yapılmaz,
-- ancak ihtiyaç halinde kullanılabilir.
-- ================================================================

DROP FUNCTION IF EXISTS maintenance.drop_expired_partitions(INT);

CREATE OR REPLACE FUNCTION maintenance.drop_expired_partitions(
    p_retention_days INT DEFAULT 36500    -- Saklama süresi (gün), varsayılan ~100 yıl
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_cutoff_date DATE;
    v_partition RECORD;
    v_dropped_count INT := 0;
    v_details JSONB := '[]'::JSONB;
    v_sql TEXT;
BEGIN
    v_cutoff_date := CURRENT_DATE - (p_retention_days || ' days')::INTERVAL;

    -- Partition tablolarını bul ve süresi dolmuş olanları tespit et
    FOR v_partition IN
        SELECT
            nmsp_parent.nspname AS parent_schema,
            parent.relname      AS parent_table,
            nmsp_child.nspname  AS child_schema,
            child.relname       AS child_table,
            pg_get_expr(child.relpartbound, child.oid) AS partition_expression
        FROM pg_inherits
        JOIN pg_class parent ON pg_inherits.inhparent = parent.oid
        JOIN pg_class child  ON pg_inherits.inhrelid  = child.oid
        JOIN pg_namespace nmsp_parent ON parent.relnamespace = nmsp_parent.oid
        JOIN pg_namespace nmsp_child  ON child.relnamespace  = nmsp_child.oid
        WHERE nmsp_parent.nspname IN ('performance', 'finance', 'billing')
          AND child.relname !~ '_default$'  -- Default partition'ları hariç tut
        ORDER BY child.relname
    LOOP
        -- Partition adından tarih bilgisini çıkar (format: *_yYYYYmMM)
        DECLARE
            v_year INT;
            v_month INT;
            v_partition_date DATE;
        BEGIN
            v_year := SUBSTRING(v_partition.child_table FROM '_y(\d{4})m\d{2}$')::INT;
            v_month := SUBSTRING(v_partition.child_table FROM '_y\d{4}m(\d{2})$')::INT;

            -- Geçersiz format ise atla
            IF v_year IS NULL OR v_month IS NULL THEN
                CONTINUE;
            END IF;

            v_partition_date := MAKE_DATE(v_year, v_month, 1);

            -- Partition süresi dolmuş mu kontrol et
            IF v_partition_date < v_cutoff_date THEN
                v_sql := FORMAT(
                    'DROP TABLE IF EXISTS %I.%I',
                    v_partition.child_schema,
                    v_partition.child_table
                );

                EXECUTE v_sql;
                v_dropped_count := v_dropped_count + 1;

                v_details := v_details || jsonb_build_object(
                    'action', 'dropped',
                    'partition', v_partition.child_schema || '.' || v_partition.child_table,
                    'partition_date', v_partition_date,
                    'parent_table', v_partition.parent_schema || '.' || v_partition.parent_table
                );
            END IF;
        END;
    END LOOP;

    RETURN jsonb_build_object(
        'dropped_count', v_dropped_count,
        'retention_days', p_retention_days,
        'cutoff_date', v_cutoff_date,
        'details', v_details,
        'executed_at', NOW()
    );
END;
$$;

COMMENT ON FUNCTION maintenance.drop_expired_partitions IS 'Drops expired monthly partitions older than retention period. Default retention is 36500 days (indefinite) since this is business data. Available for manual cleanup if ever needed. Returns JSONB with drop details.';
