-- ================================================================
-- USER_LOGIN_FAILED_INCREMENT: Başarısız login sayacını artır
-- ================================================================

DROP FUNCTION IF EXISTS security.user_login_failed_increment(BIGINT, INT, INT);

CREATE OR REPLACE FUNCTION security.user_login_failed_increment(
    p_user_id BIGINT,
    p_lock_threshold INT DEFAULT 5,
    p_lock_duration_minutes INT DEFAULT 30
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_count INT;
    v_is_locked BOOLEAN := FALSE;
    v_locked_until TIMESTAMPTZ;
BEGIN
    -- Sayacı artır
    UPDATE security.users
    SET
        failed_login_count = failed_login_count + 1,
        is_locked = CASE WHEN failed_login_count + 1 >= p_lock_threshold THEN TRUE ELSE is_locked END,
        locked_until = CASE WHEN failed_login_count + 1 >= p_lock_threshold THEN NOW() + (p_lock_duration_minutes || ' minutes')::INTERVAL ELSE locked_until END
    WHERE id = p_user_id
    RETURNING failed_login_count, is_locked, locked_until
    INTO v_new_count, v_is_locked, v_locked_until;

    RETURN jsonb_build_object(
        'failedLoginCount', v_new_count,
        'isLocked', v_is_locked,
        'lockedUntil', v_locked_until
    );
END;
$$;

COMMENT ON FUNCTION security.user_login_failed_increment IS 'Increments failed login count, locks account if threshold exceeded';
