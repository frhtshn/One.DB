-- ================================================================
-- DEPARTMENT_LIST: Departman listesi
-- Şirkete ait departmanları filtreli olarak listeler
-- Arama: JSONB name değerlerinin tümünde veya code'da arar
-- Erişim: Platform Admin (tüm şirketler), CompanyAdmin (kendi şirketi)
-- IDOR korumalı: user_assert_access_company
-- ================================================================

DROP FUNCTION IF EXISTS core.department_list(BIGINT, BIGINT, BIGINT, BOOLEAN, TEXT);

CREATE OR REPLACE FUNCTION core.department_list(
    p_caller_id BIGINT,
    p_company_id BIGINT,
    p_parent_id BIGINT DEFAULT NULL,       -- NULL = tümü, değer = belirli parent altı
    p_is_active BOOLEAN DEFAULT NULL,      -- NULL = tümü, TRUE/FALSE = filtre
    p_search TEXT DEFAULT NULL             -- JSONB name değerlerinde veya code'da arama
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = core, security, pg_temp
AS $$
DECLARE
    v_items JSONB;
    v_total INTEGER;
BEGIN
    -- 1. Şirket erişim kontrolü (IDOR)
    PERFORM security.user_assert_access_company(p_caller_id, p_company_id);

    -- 2. Toplam sayı
    SELECT COUNT(*) INTO v_total
    FROM core.departments d
    WHERE d.company_id = p_company_id
      AND (p_parent_id IS NULL OR d.parent_id = p_parent_id)
      AND (p_is_active IS NULL OR d.is_active = p_is_active)
      AND (p_search IS NULL
           OR d.code ILIKE '%' || p_search || '%'
           OR EXISTS (SELECT 1 FROM jsonb_each_text(d.name) jt WHERE jt.value ILIKE '%' || p_search || '%')
      );

    -- 3. Listeyi döndür
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', d.id,
            'parentId', d.parent_id,
            'parentName', pd.name,
            'code', d.code,
            'name', d.name,
            'description', d.description,
            'isActive', d.is_active,
            'createdAt', d.created_at,
            'updatedAt', d.updated_at
        ) ORDER BY d.code
    ), '[]'::jsonb) INTO v_items
    FROM core.departments d
    LEFT JOIN core.departments pd ON pd.id = d.parent_id
    WHERE d.company_id = p_company_id
      AND (p_parent_id IS NULL OR d.parent_id = p_parent_id)
      AND (p_is_active IS NULL OR d.is_active = p_is_active)
      AND (p_search IS NULL
           OR d.code ILIKE '%' || p_search || '%'
           OR EXISTS (SELECT 1 FROM jsonb_each_text(d.name) jt WHERE jt.value ILIKE '%' || p_search || '%')
      );

    RETURN jsonb_build_object('items', v_items, 'totalCount', v_total);
END;
$$;

COMMENT ON FUNCTION core.department_list(BIGINT, BIGINT, BIGINT, BOOLEAN, TEXT) IS
'Lists departments for a company. Search works across all language values in JSONB name and code.
name, description, parentName are multi-language JSONB objects. Ordered by code.
Access: Platform Admin (all companies), CompanyAdmin (own company). IDOR protected.';
