-- ================================================================
-- USER_UNLOCK: Kilitli kullanıcı hesabını açar (Admin işlemi)
-- ================================================================

DROP FUNCTION IF EXISTS security.user_unlock(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION security.user_unlock(
    p_user_id BIGINT,
    p_unlocked_by BIGINT  -- Admin user ID (audit için)
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_user_exists BOOLEAN;
BEGIN
    -- Kullanıcı var mı kontrol et
    SELECT EXISTS (SELECT 1 FROM security.users WHERE id = p_user_id) INTO v_user_exists;

    IF NOT v_user_exists THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
    END IF;

    -- Kullanıcının kilidini aç
    UPDATE security.users
    SET is_locked = FALSE,
        locked_until = NULL,
        failed_login_count = 0
    WHERE id = p_user_id;

    RETURN jsonb_build_object(
        'userId', p_user_id,
        'unlockedBy', p_unlocked_by,
        'unlockedAt', NOW()
    );
END;
$$;

COMMENT ON FUNCTION security.user_unlock IS 'Unlocks a locked user account (Admin action)';
