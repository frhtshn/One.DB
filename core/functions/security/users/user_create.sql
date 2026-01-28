-- ================================================================
-- USER_CREATE: Yeni kullanıcı oluştur
-- ================================================================

DROP FUNCTION IF EXISTS security.user_create(TEXT, TEXT, TEXT, TEXT, TEXT, BIGINT, CHAR(2), BIGINT);

CREATE OR REPLACE FUNCTION security.user_create(
    p_email TEXT,
    p_username TEXT,
    p_password TEXT,
    p_first_name TEXT,
    p_last_name TEXT,
    p_company_id BIGINT,
    p_language CHAR(2) DEFAULT NULL,
    p_timezone VARCHAR(50) DEFAULT NULL,
    p_currency CHAR(3) DEFAULT NULL,
    p_created_by BIGINT DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_id BIGINT;
BEGIN
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

    -- Kullanıcı oluştur
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
        created_by,
        created_at,
        updated_at
    )
    VALUES (
        LOWER(TRIM(p_email)),
        LOWER(TRIM(p_username)),
        p_password,  -- Hash işlemi uygulama katmanında yapılmalı
        TRIM(p_first_name),
        TRIM(p_last_name),
        p_company_id,
        p_language,
        p_timezone,
        p_currency,
        1,  -- Aktif
        p_created_by,
        NOW(),
        NOW()
    )
    RETURNING security.users.id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION security.user_create IS 'Creates a new user with email/username uniqueness validation';
