-- ================================================================
-- PERMISSION_CATEGORY_LIST: Aktif kategorilerin listesi
-- Dogrudan JSONB array doner (wrapper yok)
-- ================================================================

DROP FUNCTION IF EXISTS security.permission_category_list();

CREATE OR REPLACE FUNCTION security.permission_category_list()
RETURNS JSONB
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN COALESCE(
        (SELECT jsonb_agg(
            jsonb_build_object(
                'category', category,
                'count', permission_count
            ) ORDER BY category
        )
        FROM (
            SELECT
                p.category,
                COUNT(*) AS permission_count
            FROM security.permissions p
            WHERE p.status = 1
            GROUP BY p.category
        ) t),
        '[]'::jsonb
    );
END;
$$;

COMMENT ON FUNCTION security.permission_category_list IS 'Lists active permission categories and count. Returns direct JSON array.';
