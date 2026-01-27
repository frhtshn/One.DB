-- ================================================================
-- LOCALIZATION_CATEGORY_LIST: Kategori Listesi
-- Domain içindeki kategorileri listeler.
-- ================================================================

DROP FUNCTION IF EXISTS catalog.localization_category_list(VARCHAR);

CREATE OR REPLACE FUNCTION catalog.localization_category_list(p_domain VARCHAR DEFAULT NULL)
RETURNS TABLE(category VARCHAR, count BIGINT)
LANGUAGE sql STABLE
AS $$
    SELECT k.category, COUNT(*) as count
    FROM catalog.localization_keys k
    WHERE p_domain IS NULL OR k.domain = p_domain
    GROUP BY k.category
    ORDER BY k.category;
$$;

COMMENT ON FUNCTION catalog.localization_category_list(VARCHAR) IS 'Lists distinct localization categories.';
