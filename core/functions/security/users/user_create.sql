-- ================================================================
-- USER_CREATE: Yeni kullanıcı oluştur (IDOR Korumalı)
-- ================================================================
-- Erişim Kuralları:
--   - Platform Admin: Her şirkete kullanıcı ekleyebilir
--   - Diğerleri: Sadece kendi şirketine (caller_company_id == p_company_id)
-- ================================================================

DROP FUNCTION IF EXISTS security.user_create(BIGINT, TEXT, TEXT, TEXT, TEXT, TEXT, BIGINT, CHAR(2), VARCHAR(50), CHAR(3));

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
    p_currency CHAR(3) DEFAULT NULL
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
        1,
        NOW(),
        TRUE,  -- Yeni kullanıcı ilk girişte şifresini değiştirmeli
        p_caller_id,
        NOW(),
        NOW()
    )
    RETURNING security.users.id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION security.user_create(BIGINT, TEXT, TEXT, TEXT, TEXT, TEXT, BIGINT, CHAR(2), VARCHAR(50), CHAR(3)) IS
'Creates a new user with IDOR protection.
Access: Platform Admin (any company), Others (own company only).';
