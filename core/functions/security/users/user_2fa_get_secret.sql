-- ================================================================
-- USER_2FA_GET_SECRET: Kullanicinin 2FA secret'ini doner
-- ================================================================
-- Grain'de TOTP dogrulama icin kullanilir.
-- 2FA aktif degilse NULL doner.
-- ================================================================

DROP FUNCTION IF EXISTS security.user_2fa_get_secret(BIGINT);

CREATE OR REPLACE FUNCTION security.user_2fa_get_secret(
    p_user_id BIGINT
)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = security, pg_temp
AS $$
DECLARE
    v_secret TEXT;
BEGIN
    SELECT two_factor_secret INTO v_secret
    FROM security.users
    WHERE id = p_user_id
      AND two_factor_enabled = TRUE;

    RETURN v_secret;
END;
$$;

COMMENT ON FUNCTION security.user_2fa_get_secret(BIGINT) IS
'Returns user 2FA secret for TOTP verification in Grain.
Returns NULL if user not found or 2FA is not enabled.';
