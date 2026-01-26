-- ============================================================================
-- LOCALIZATION KEY FUNCTIONS
-- ============================================================================

DROP FUNCTION IF EXISTS catalog.localization_key_list(INT, INT, VARCHAR, VARCHAR, VARCHAR);

-- localization_key_list: Sayfalı key listesi
CREATE OR REPLACE FUNCTION catalog.localization_key_list(
    p_page INT DEFAULT 1,
    p_page_size INT DEFAULT 20,
    p_domain VARCHAR DEFAULT NULL,
    p_category VARCHAR DEFAULT NULL,
    p_search VARCHAR DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql STABLE
AS $$
DECLARE
    v_offset INT;
    v_total INT;
    v_items JSONB;
BEGIN
    v_offset := (p_page - 1) * p_page_size;

    -- Total count
    SELECT COUNT(*) INTO v_total
    FROM catalog.localization_keys k
    WHERE (p_domain IS NULL OR k.domain = p_domain)
      AND (p_category IS NULL OR k.category = p_category)
      AND (p_search IS NULL OR k.localization_key ILIKE '%' || p_search || '%');

    -- Items with translation counts
    SELECT COALESCE(jsonb_agg(row_to_json(t)::jsonb ORDER BY t.key), '[]'::jsonb)
    INTO v_items
    FROM (
        SELECT
            k.id,
            k.localization_key AS key,
            k.domain,
            k.category,
            k.description,
            (SELECT COUNT(*) FROM catalog.localization_values v WHERE v.localization_key_id = k.id) AS "translationCount"
        FROM catalog.localization_keys k
        WHERE (p_domain IS NULL OR k.domain = p_domain)
          AND (p_category IS NULL OR k.category = p_category)
          AND (p_search IS NULL OR k.localization_key ILIKE '%' || p_search || '%')
        ORDER BY k.localization_key
        LIMIT p_page_size OFFSET v_offset
    ) t;

    RETURN jsonb_build_object('items', v_items, 'totalCount', v_total);
END;
$$;

COMMENT ON FUNCTION catalog.localization_key_list(INT, INT, VARCHAR, VARCHAR, VARCHAR) IS 'Lists localization keys with pagination and filtering.';
