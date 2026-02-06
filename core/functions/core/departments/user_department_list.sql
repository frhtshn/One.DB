-- ================================================================
-- USER_DEPARTMENT_LIST: Kullanıcının departmanlarını listele
-- Kullanıcıya atanmış tüm departmanları döner
-- departmentName ve parentName çoklu dil JSONB formatında döner
-- Erişim: Kullanıcının şirketine erişim gerektirir
-- IDOR korumalı: user_assert_access_company
-- ================================================================

DROP FUNCTION IF EXISTS core.user_department_list(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION core.user_department_list(
    p_caller_id BIGINT,
    p_user_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = core, security, pg_temp
AS $$
DECLARE
    v_user_company_id BIGINT;
    v_items JSONB;
BEGIN
    -- 1. Kullanıcı bilgisini al
    SELECT company_id INTO v_user_company_id
    FROM security.users
    WHERE id = p_user_id AND status = 1;

    IF v_user_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
    END IF;

    -- 2. Şirket erişim kontrolü (IDOR)
    PERFORM security.user_assert_access_company(p_caller_id, v_user_company_id);

    -- 3. Departman listesini al
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', ud.id,
            'departmentId', d.id,
            'departmentCode', d.code,
            'departmentName', d.name,
            'parentId', d.parent_id,
            'parentName', pd.name,
            'isPrimary', ud.is_primary,
            'isActive', d.is_active,
            'assignedAt', ud.assigned_at
        ) ORDER BY ud.is_primary DESC, d.code
    ), '[]'::jsonb) INTO v_items
    FROM core.user_departments ud
    JOIN core.departments d ON d.id = ud.department_id
    LEFT JOIN core.departments pd ON pd.id = d.parent_id
    WHERE ud.user_id = p_user_id;

    RETURN v_items;
END;
$$;

COMMENT ON FUNCTION core.user_department_list(BIGINT, BIGINT) IS
'Lists all departments assigned to a user. Primary department listed first.
departmentName and parentName are multi-language JSONB objects.
Access: Platform Admin (all companies), CompanyAdmin (own company). IDOR protected.';
