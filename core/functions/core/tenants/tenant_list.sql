-- ================================================================
-- TENANT_LIST: Tenant listesini getirir
-- Filtreleme ve sayfalama destekler.
-- Supported Currencies/Languages listesi de (string array olarak) döner.
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_list(INTEGER, INTEGER, BIGINT, TEXT);
DROP FUNCTION IF EXISTS core.tenant_list(INTEGER, INTEGER, BIGINT, TEXT, INTEGER);

CREATE OR REPLACE FUNCTION core.tenant_list(
    p_page INTEGER DEFAULT 1,
    p_page_size INTEGER DEFAULT 20,
    p_company_id BIGINT DEFAULT NULL,
    p_search TEXT DEFAULT NULL,
    p_status INTEGER DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_offset INTEGER;
    v_total_count INTEGER;
    v_items JSONB;
BEGIN
    v_offset := (p_page - 1) * p_page_size;

    -- Total Count
    SELECT COUNT(*) INTO v_total_count
    FROM core.tenants t
    JOIN core.companies c ON t.company_id = c.id
    WHERE (p_company_id IS NULL OR t.company_id = p_company_id)
    AND (p_status IS NULL OR t.status = p_status)
    AND (p_search IS NULL OR
         t.tenant_name ILIKE '%' || p_search || '%' OR
         t.tenant_code ILIKE '%' || p_search || '%');

    -- Items
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', t.id,
            'companyId', t.company_id,
            'companyName', c.company_name,
            'tenantCode', t.tenant_code,
            'tenantName', t.tenant_name,
            'environment', t.environment,
            'status', t.status,
            'baseCurrency', t.base_currency,
            'defaultLanguage', t.default_language,
            'defaultCountry', t.default_country,
            'createdAt', t.created_at,
            'supportedCurrencies', COALESCE((
                SELECT jsonb_agg(tc.currency_code ORDER BY tc.currency_code)
                FROM core.tenant_currencies tc
                WHERE tc.tenant_id = t.id AND tc.is_enabled = TRUE
            ), '[]'::jsonb),
            'supportedLanguages', COALESCE((
                SELECT jsonb_agg(tl.language_code ORDER BY tl.language_code)
                FROM core.tenant_languages tl
                WHERE tl.tenant_id = t.id AND tl.is_enabled = TRUE
            ), '[]'::jsonb)
        ) ORDER BY t.created_at DESC
    ), '[]'::jsonb)
    INTO v_items
    FROM (
        SELECT * FROM core.tenants t
        WHERE (p_company_id IS NULL OR t.company_id = p_company_id)
        AND (p_status IS NULL OR t.status = p_status)
        AND (p_search IS NULL OR
             t.tenant_name ILIKE '%' || p_search || '%' OR
             t.tenant_code ILIKE '%' || p_search || '%')
        ORDER BY t.created_at DESC
        LIMIT p_page_size OFFSET v_offset
    ) t
    JOIN core.companies c ON t.company_id = c.id;

    RETURN jsonb_build_object(
        'items', v_items,
        'totalCount', v_total_count,
        'page', p_page,
        'pageSize', p_page_size
    );
END;
$$;

COMMENT ON FUNCTION core.tenant_list(INTEGER, INTEGER, BIGINT, TEXT, INTEGER) IS 'Lists tenants with pagination, filter (company, search, status), and configuration details.';

