-- ================================================================
-- DEPARTMENT_GET: Departman detay bilgisi
-- Departman bilgilerini üst departman adı ile birlikte döner
-- name ve description çoklu dil JSONB formatında döner
-- Erişim: Platform Admin (tüm şirketler), CompanyAdmin (kendi şirketi)
-- IDOR korumalı: user_assert_access_company
-- ================================================================

DROP FUNCTION IF EXISTS core.department_get(BIGINT, BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION core.department_get(
    p_caller_id BIGINT,
    p_company_id BIGINT,
    p_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = core, security, pg_temp
AS $$
DECLARE
    v_result JSONB;
BEGIN
    -- 1. Şirket erişim kontrolü (IDOR)
    PERFORM security.user_assert_access_company(p_caller_id, p_company_id);

    -- 2. Departman bilgisini al
    SELECT jsonb_build_object(
        'id', d.id,
        'companyId', d.company_id,
        'parentId', d.parent_id,
        'parentName', pd.name,
        'code', d.code,
        'name', d.name,
        'description', d.description,
        'isActive', d.is_active,
        'createdAt', d.created_at,
        'updatedAt', d.updated_at
    )
    INTO v_result
    FROM core.departments d
    LEFT JOIN core.departments pd ON pd.id = d.parent_id
    WHERE d.id = p_id AND d.company_id = p_company_id;

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.department.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION core.department_get(BIGINT, BIGINT, BIGINT) IS
'Returns department details by ID with parent department name.
name, description, parentName are multi-language JSONB objects.
Access: Platform Admin (all companies), CompanyAdmin (own company). IDOR protected.';
