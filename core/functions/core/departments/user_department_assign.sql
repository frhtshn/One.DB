-- ================================================================
-- USER_DEPARTMENT_ASSIGN: Kullanıcıyı departmana ata
-- Kullanıcıyı belirtilen departmana atar
-- is_primary=TRUE ise mevcut primary'yi FALSE yapar
-- Erişim: Departmanın şirketine erişim gerektirir
-- IDOR korumalı: user_assert_access_company
-- ================================================================

DROP FUNCTION IF EXISTS core.user_department_assign(BIGINT, BIGINT, BIGINT, BOOLEAN);

CREATE OR REPLACE FUNCTION core.user_department_assign(
    p_caller_id BIGINT,
    p_user_id BIGINT,
    p_department_id BIGINT,
    p_is_primary BOOLEAN DEFAULT FALSE
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = core, security, pg_temp
AS $$
DECLARE
    v_dept_company_id BIGINT;
    v_user_company_id BIGINT;
BEGIN
    -- 1. Departman bilgisini al
    SELECT company_id INTO v_dept_company_id
    FROM core.departments
    WHERE id = p_department_id AND is_active = TRUE;

    IF v_dept_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.department.not-found';
    END IF;

    -- 2. Şirket erişim kontrolü (IDOR)
    PERFORM security.user_assert_access_company(p_caller_id, v_dept_company_id);

    -- 3. Kullanıcı varlık ve şirket kontrolü
    SELECT company_id INTO v_user_company_id
    FROM security.users
    WHERE id = p_user_id AND status = 1;

    IF v_user_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
    END IF;

    -- 4. Kullanıcı aynı şirkette olmalı
    IF v_user_company_id <> v_dept_company_id THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.department.user-company-mismatch';
    END IF;

    -- 5. Zaten atanmış mı?
    IF EXISTS (SELECT 1 FROM core.user_departments WHERE user_id = p_user_id AND department_id = p_department_id) THEN
        -- Sadece is_primary güncelle
        IF p_is_primary THEN
            UPDATE core.user_departments SET is_primary = FALSE
            WHERE user_id = p_user_id AND is_primary = TRUE AND department_id <> p_department_id;

            UPDATE core.user_departments SET is_primary = TRUE
            WHERE user_id = p_user_id AND department_id = p_department_id;
        END IF;
        RETURN;
    END IF;

    -- 6. is_primary=TRUE ise mevcut primary'yi FALSE yap
    IF p_is_primary THEN
        UPDATE core.user_departments SET is_primary = FALSE
        WHERE user_id = p_user_id AND is_primary = TRUE;
    END IF;

    -- 7. Atama yap
    INSERT INTO core.user_departments (user_id, department_id, is_primary, assigned_at, assigned_by)
    VALUES (p_user_id, p_department_id, p_is_primary, NOW(), p_caller_id);
END;
$$;

COMMENT ON FUNCTION core.user_department_assign(BIGINT, BIGINT, BIGINT, BOOLEAN) IS
'Assigns a user to a department. If is_primary=TRUE, unsets previous primary.
Idempotent: if already assigned, only updates is_primary if needed.
User and department must belong to the same company. IDOR protected.';
