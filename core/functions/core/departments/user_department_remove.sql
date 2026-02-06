-- ================================================================
-- USER_DEPARTMENT_REMOVE: Kullanıcıyı departmandan çıkar
-- Kullanıcının departman atamasını siler
-- Erişim: Departmanın şirketine erişim gerektirir
-- IDOR korumalı: user_assert_access_company
-- ================================================================

DROP FUNCTION IF EXISTS core.user_department_remove(BIGINT, BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION core.user_department_remove(
    p_caller_id BIGINT,
    p_user_id BIGINT,
    p_department_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = core, security, pg_temp
AS $$
DECLARE
    v_dept_company_id BIGINT;
BEGIN
    -- 1. Departman bilgisini al
    SELECT company_id INTO v_dept_company_id
    FROM core.departments
    WHERE id = p_department_id;

    IF v_dept_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.department.not-found';
    END IF;

    -- 2. Şirket erişim kontrolü (IDOR)
    PERFORM security.user_assert_access_company(p_caller_id, v_dept_company_id);

    -- 3. Atama varlık kontrolü
    IF NOT EXISTS (SELECT 1 FROM core.user_departments WHERE user_id = p_user_id AND department_id = p_department_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user-department.not-found';
    END IF;

    -- 4. Atamayı sil
    DELETE FROM core.user_departments
    WHERE user_id = p_user_id AND department_id = p_department_id;
END;
$$;

COMMENT ON FUNCTION core.user_department_remove(BIGINT, BIGINT, BIGINT) IS
'Removes a user from a department (hard delete on junction table).
Access: Platform Admin (all companies), CompanyAdmin (own company). IDOR protected.';
