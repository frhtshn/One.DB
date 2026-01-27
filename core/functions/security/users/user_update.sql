-- ================================================================
-- USER_UPDATE: Kullanıcı güncelle
-- NULL gelen alanlar güncellenmez (partial update)
-- ================================================================

DROP FUNCTION IF EXISTS security.user_update(BIGINT, TEXT, TEXT, TEXT, TEXT, SMALLINT, CHAR(2), BOOLEAN, BIGINT);

CREATE OR REPLACE FUNCTION security.user_update(
    p_user_id BIGINT,
    p_first_name TEXT DEFAULT NULL,
    p_last_name TEXT DEFAULT NULL,
    p_email TEXT DEFAULT NULL,
    p_username TEXT DEFAULT NULL,
    p_status SMALLINT DEFAULT NULL,
    p_language CHAR(2) DEFAULT NULL,
    p_two_factor_enabled BOOLEAN DEFAULT NULL,
    p_updated_by BIGINT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_user RECORD;
BEGIN
    -- Kullanıcı var mı ve silinmemiş mi kontrol et
    SELECT id, company_id, email, username, status
    INTO v_current_user
    FROM security.users
    WHERE id = p_user_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
    END IF;


    -- Email benzersizlik kontrolü (değişiyorsa)
    IF p_email IS NOT NULL AND LOWER(TRIM(p_email)) != v_current_user.email THEN
        IF EXISTS (SELECT 1 FROM security.users WHERE email = LOWER(TRIM(p_email)) AND id != p_user_id) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.user.update.email-exists';
        END IF;
    END IF;

    -- Username benzersizlik kontrolü (değişiyorsa, aynı company içinde)
    IF p_username IS NOT NULL AND LOWER(TRIM(p_username)) != v_current_user.username THEN
        IF EXISTS (
            SELECT 1 FROM security.users
            WHERE company_id = v_current_user.company_id
              AND username = LOWER(TRIM(p_username))
              AND id != p_user_id
        ) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.user.update.username-exists';
        END IF;
    END IF;

    -- Güncelleme (NULL olanlar mevcut değeri korur)
    UPDATE security.users
    SET first_name = COALESCE(TRIM(p_first_name), first_name),
        last_name = COALESCE(TRIM(p_last_name), last_name),
        email = COALESCE(LOWER(TRIM(p_email)), email),
        username = COALESCE(LOWER(TRIM(p_username)), username),
        status = COALESCE(p_status, status),
        language = COALESCE(p_language, language),
        two_factor_enabled = COALESCE(p_two_factor_enabled, two_factor_enabled),
        updated_at = NOW(),
        updated_by = p_updated_by
    WHERE id = p_user_id;
END;
$$;

COMMENT ON FUNCTION security.user_update IS 'Updates user with partial update support. NULL values keep existing data. Validates email/username uniqueness.';
