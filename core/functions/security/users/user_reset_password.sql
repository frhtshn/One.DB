-- ================================================================
-- USER_RESET_PASSWORD: Kullanıcı şifresini sıfırla
-- Admin tarafından yapılan şifre sıfırlama işlemi
-- ================================================================

DROP FUNCTION IF EXISTS security.user_reset_password(BIGINT, TEXT, BIGINT);

CREATE OR REPLACE FUNCTION security.user_reset_password(
    p_user_id BIGINT,
    p_new_password TEXT,
    p_reset_by BIGINT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_status SMALLINT;
BEGIN
    -- Kullanıcı var mı kontrol et
    SELECT status
    INTO v_current_status
    FROM security.users
    WHERE id = p_user_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
    END IF;

    -- Silinmiş kullanıcının şifresi sıfırlanamaz
    IF v_current_status = -1 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.user.reset-password.is-deleted';
    END IF;

    -- Şifreyi güncelle
    UPDATE security.users
    SET password = p_new_password,  -- Hash işlemi uygulama katmanında yapılmalı
        updated_at = NOW(),
        updated_by = p_reset_by
    WHERE id = p_user_id;
END;
$$;

COMMENT ON FUNCTION security.user_reset_password IS 'Resets user password (admin action). Password should be hashed before calling.';
