-- ================================================================
-- USER_GET_PASSWORD_HASH: Kullanıcının mevcut şifre hash'ini döner
-- ================================================================
-- Grain'de Argon2id Verify için kullanılır.
-- Change password işleminde mevcut şifre doğrulaması için.
-- ================================================================

DROP FUNCTION IF EXISTS security.user_get_password_hash(BIGINT);

CREATE OR REPLACE FUNCTION security.user_get_password_hash(
    p_user_id BIGINT
)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = security, pg_temp
AS $$
DECLARE
    v_password_hash TEXT;
BEGIN
    SELECT password INTO v_password_hash
    FROM security.users
    WHERE id = p_user_id;

    RETURN v_password_hash;
END;
$$;

COMMENT ON FUNCTION security.user_get_password_hash(BIGINT) IS
'Returns user password hash for Argon2id Verify in Grain.
Returns NULL if user not found.';
