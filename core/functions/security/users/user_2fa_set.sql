-- ================================================================
-- USER_2FA_SET: 2FA durumunu ayarlar (enable/disable tek function)
-- ================================================================
-- Enable: p_enabled=true, p_secret='base32secret'
-- Disable: p_enabled=false, p_secret=NULL
-- Guvenlik: Disable isleminde secret otomatik NULL yapilir.
-- ================================================================

DROP FUNCTION IF EXISTS security.user_2fa_set(BIGINT, BOOLEAN, VARCHAR);

CREATE OR REPLACE FUNCTION security.user_2fa_set(
    p_user_id BIGINT,
    p_enabled BOOLEAN,
    p_secret VARCHAR(255) DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = security, pg_temp
AS $$
BEGIN
    -- Kullanici kontrolu
    IF NOT EXISTS (SELECT 1 FROM security.users WHERE id = p_user_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
    END IF;

    -- Disable isleminde secret her zaman NULL olmali (guvenlik)
    IF NOT p_enabled THEN
        p_secret := NULL;
    END IF;

    UPDATE security.users
    SET two_factor_enabled = p_enabled,
        two_factor_secret = p_secret,
        updated_at = NOW()
    WHERE id = p_user_id;
END;
$$;

COMMENT ON FUNCTION security.user_2fa_set(BIGINT, BOOLEAN, VARCHAR) IS
'Sets 2FA status for a user. Enable: p_enabled=true with p_secret. Disable: p_enabled=false (secret auto-cleared).
Raises P0404 if user not found.';
