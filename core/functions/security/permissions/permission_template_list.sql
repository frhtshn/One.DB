-- ================================================================
-- PERMISSION_TEMPLATE_LIST: Sayfalamali template listesi
-- Filtreler: company_id, search (code/name), is_active
-- IDOR: Company filtreli
-- Returns: JSONB - items + totalCount
-- ================================================================

DROP FUNCTION IF EXISTS security.permission_template_list(BIGINT, INT, INT, VARCHAR, BOOLEAN);

CREATE OR REPLACE FUNCTION security.permission_template_list(
    p_caller_id BIGINT,
    p_page INT DEFAULT 1,
    p_page_size INT DEFAULT 20,
    p_search VARCHAR(100) DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_offset INT;
    v_items JSONB;
    v_total_count BIGINT;
    v_caller_company_id BIGINT;
    v_has_platform_role BOOLEAN;
BEGIN
    v_offset := (p_page - 1) * p_page_size;

    -- ========================================
    -- CALLER BILGISI
    -- ========================================
    SELECT u.company_id FROM security.users u
    WHERE u.id = p_caller_id AND u.status = 1
    INTO v_caller_company_id;

    IF v_caller_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.unauthorized';
    END IF;

    SELECT EXISTS(
        SELECT 1 FROM security.user_roles ur
        JOIN security.roles r ON ur.role_id = r.id
        WHERE ur.user_id = p_caller_id AND ur.tenant_id IS NULL AND r.is_platform_role = TRUE
    ) INTO v_has_platform_role;

    -- ========================================
    -- TOTAL COUNT
    -- ========================================
    SELECT COUNT(*)
    INTO v_total_count
    FROM security.permission_templates pt
    WHERE pt.deleted_at IS NULL
      AND (p_is_active IS NULL OR pt.is_active = p_is_active)
      AND (p_search IS NULL OR pt.code ILIKE '%' || p_search || '%' OR pt.name ILIKE '%' || p_search || '%')
      -- IDOR: Platform admin hepsini gorur, diger kullanicilar sadece kendi sirketini + platform template'leri
      AND (v_has_platform_role OR pt.company_id = v_caller_company_id OR pt.company_id IS NULL);

    -- ========================================
    -- ITEMS
    -- ========================================
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', sub.id,
            'code', sub.code,
            'name', sub.name,
            'isActive', sub.is_active,
            'companyId', sub.company_id,
            'itemCount', sub.item_count,
            'createdAt', sub.created_at
        ) ORDER BY sub.code
    ), '[]'::jsonb)
    INTO v_items
    FROM (
        SELECT
            pt.id,
            pt.code,
            pt.name,
            pt.is_active,
            pt.company_id,
            pt.created_at,
            (SELECT COUNT(*) FROM security.permission_template_items pti WHERE pti.template_id = pt.id) AS item_count
        FROM security.permission_templates pt
        WHERE pt.deleted_at IS NULL
          AND (p_is_active IS NULL OR pt.is_active = p_is_active)
          AND (p_search IS NULL OR pt.code ILIKE '%' || p_search || '%' OR pt.name ILIKE '%' || p_search || '%')
          AND (v_has_platform_role OR pt.company_id = v_caller_company_id OR pt.company_id IS NULL)
        ORDER BY pt.code
        LIMIT p_page_size OFFSET v_offset
    ) sub;

    RETURN jsonb_build_object(
        'items', v_items,
        'totalCount', v_total_count
    );
END;
$$;

COMMENT ON FUNCTION security.permission_template_list IS 'Paginated template list with company scope filtering. Platform admins see all, others see own company + platform templates.';
