-- ================================================================
-- USER_PASSWORD_HISTORY_LIST: Kullanıcının son N şifre hash'ini döner
-- ================================================================
-- Grain'de Argon2id Verify ile history kontrolü için kullanılır.
-- N değeri company_password_policy'den alınır (default: 3).
-- ================================================================

DROP FUNCTION IF EXISTS security.user_password_history_list(BIGINT);

CREATE OR REPLACE FUNCTION security.user_password_history_list(
    p_user_id BIGINT
)
RETURNS SETOF VARCHAR(255)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = security, pg_temp
AS $$
DECLARE
    v_history_count INT := 3;
    v_company_id BIGINT;
BEGIN
    -- Company ID al
    SELECT company_id INTO v_company_id
    FROM security.users WHERE id = p_user_id;

    -- History count al (company policy veya default)
    SELECT COALESCE(
        (SELECT cpp.history_count FROM security.company_password_policy cpp
         WHERE cpp.company_id = v_company_id),
        3
    ) INTO v_history_count;

    -- Son N hash'i dön
    RETURN QUERY
    SELECT uph.password_hash
    FROM security.user_password_history uph
    WHERE uph.user_id = p_user_id
    ORDER BY uph.changed_at DESC
    LIMIT v_history_count;
END;
$$;

COMMENT ON FUNCTION security.user_password_history_list(BIGINT) IS
'Returns last N password hashes for history validation in Grain (Argon2id Verify).
N is determined by company_password_policy.history_count (default: 3).';
