-- ================================================================
-- USER_CREATE: Yeni kullanıcı oluştur (IDOR Korumalı)
-- ================================================================
-- Erişim Kuralları:
--   - Platform Admin: Her şirkete kullanıcı ekleyebilir
--   - Diğerleri: Sadece kendi şirketine (caller_company_id == p_company_id)
-- p_department_id verilirse kullanıcı o departmana primary olarak atanır
-- ================================================================

DROP FUNCTION IF EXISTS security.user_create(BIGINT, TEXT, TEXT, TEXT, TEXT, TEXT, BIGINT, CHAR(2), VARCHAR(50), CHAR(3), CHAR(2), BIGINT);

CREATE OR REPLACE FUNCTION security.user_create(
    p_caller_id BIGINT,
    p_email TEXT,
    p_username TEXT,
    p_password TEXT,
    p_first_name TEXT,
    p_last_name TEXT,
    p_company_id BIGINT,
    p_language CHAR(2) DEFAULT NULL,
    p_timezone VARCHAR(50) DEFAULT NULL,
    p_currency CHAR(3) DEFAULT NULL,
    p_country CHAR(2) DEFAULT NULL,
    p_department_id BIGINT DEFAULT NULL       -- Atanacak departman (primary olarak)
)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_new_id BIGINT;
BEGIN
    -- 1. Company erişim kontrolü
    PERFORM security.user_assert_access_company(p_caller_id, p_company_id);

    -- ========================================
    -- 2. VALIDASYONLAR
    -- ========================================
    -- Email benzersizlik kontrolü
    IF EXISTS (SELECT 1 FROM security.users WHERE email = LOWER(TRIM(p_email))) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.user.create.email-exists';
    END IF;

    -- Username + Company benzersizlik kontrolü
    IF EXISTS (SELECT 1 FROM security.users WHERE company_id = p_company_id AND username = LOWER(TRIM(p_username))) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.user.create.username-exists';
    END IF;

    -- Company varlık kontrolü
    IF NOT EXISTS (SELECT 1 FROM core.companies WHERE id = p_company_id AND status = 1) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.company.not-found';
    END IF;

    -- Departman varlık kontrolü (verilmişse)
    IF p_department_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM core.departments
            WHERE id = p_department_id AND company_id = p_company_id AND is_active = TRUE
        ) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.department.not-found';
        END IF;
    END IF;

    -- ========================================
    -- 4. KULLANICI OLUŞTUR
    -- ========================================
    INSERT INTO security.users (
        email,
        username,
        password,
        first_name,
        last_name,
        company_id,
        language,
        timezone,
        currency,
        country,
        status,
        password_changed_at,
        require_password_change,
        created_by,
        created_at,
        updated_at
    )
    VALUES (
        LOWER(TRIM(p_email)),
        LOWER(TRIM(p_username)),
        p_password,
        TRIM(p_first_name),
        TRIM(p_last_name),
        p_company_id,
        p_language,
        p_timezone,
        p_currency,
        p_country,
        1,
        NOW(),
        TRUE,  -- Yeni kullanıcı ilk girişte şifresini değiştirmeli
        p_caller_id,
        NOW(),
        NOW()
    )
    RETURNING security.users.id INTO v_new_id;

    -- Departman ataması (verilmişse, primary olarak)
    IF p_department_id IS NOT NULL THEN
        INSERT INTO core.user_departments (user_id, department_id, is_primary, assigned_by)
        VALUES (v_new_id, p_department_id, TRUE, p_caller_id);
    END IF;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION security.user_create(BIGINT, TEXT, TEXT, TEXT, TEXT, TEXT, BIGINT, CHAR(2), VARCHAR(50), CHAR(3), CHAR(2), BIGINT) IS
'Creates a new user with IDOR protection.
p_department_id: optional, assigns user to department as primary.
Department must belong to same company and be active.
Access: Platform Admin (any company), Others (own company only).';
