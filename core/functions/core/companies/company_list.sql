
-- ================================================================
-- COMPANY_LIST: Şirketleri listele (sayfalı)
-- Yönetim paneli için şirket listesini, arama ve ülke adı ile döner
-- Returns paginated company list for management UI, with search and country name
-- ================================================================

DROP FUNCTION IF EXISTS core.company_list(INTEGER, INTEGER, TEXT);
DROP FUNCTION IF EXISTS core.company_list(INTEGER, INTEGER, TEXT, SMALLINT);

CREATE OR REPLACE FUNCTION core.company_list(
    p_page INTEGER DEFAULT 1,
    p_page_size INTEGER DEFAULT 20,
    p_search TEXT DEFAULT NULL,
    p_status SMALLINT DEFAULT 1
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_offset INTEGER := (p_page - 1) * p_page_size;
    v_items JSONB;
    v_total INTEGER;
BEGIN
    -- Sayfa ve sayfa boyutu doğrulama
    IF p_page < 1 OR p_page_size < 1 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.pagination.invalid';
    END IF;

    SELECT COUNT(*) INTO v_total
    FROM core.companies c
    WHERE (p_search IS NULL OR c.company_name ILIKE '%' || p_search || '%' OR c.company_code ILIKE '%' || p_search || '%')
      AND (p_status IS NULL OR c.status = p_status);

    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', c.id,
            'companyCode', c.company_code,
            'companyName', c.company_name,
            'status', c.status,
            'countryCode', c.country_code,
            'countryName', co.country_name,
            'timezone', c.timezone,
            'createdAt', c.created_at,
            'updatedAt', c.updated_at
        ) ORDER BY c.id DESC
    ), '[]'::jsonb) INTO v_items
    FROM core.companies c
    LEFT JOIN catalog.countries co ON co.country_code = c.country_code
    WHERE (p_search IS NULL OR c.company_name ILIKE '%' || p_search || '%' OR c.company_code ILIKE '%' || p_search || '%')
      AND (p_status IS NULL OR c.status = p_status)
    OFFSET v_offset LIMIT p_page_size;

    RETURN jsonb_build_object('items', v_items, 'totalCount', v_total);
END;
$$;

COMMENT ON FUNCTION core.company_list(INTEGER, INTEGER, TEXT, SMALLINT) IS 'Returns a paginated list of companies for management UI. Searchable by name or code. Filterable by status (NULL=all, 0=deleted, 1=active).';
