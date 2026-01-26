-- ================================================================
-- SESSION_SAVE: Yeni oturum kaydet veya güncelle
-- ================================================================

DROP FUNCTION IF EXISTS security.session_save(VARCHAR, BIGINT, VARCHAR, VARCHAR, VARCHAR, VARCHAR, TIMESTAMPTZ);

CREATE OR REPLACE FUNCTION security.session_save(
    p_session_id VARCHAR(50),
    p_user_id BIGINT,
    p_refresh_token_id VARCHAR(100),
    p_ip_address VARCHAR(50),
    p_user_agent VARCHAR(500),
    p_device_name VARCHAR(100),
    p_expires_at TIMESTAMPTZ
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO security.user_sessions (
        id, user_id, refresh_token_id, ip_address, user_agent, device_name, expires_at
    )
    VALUES (
        p_session_id, p_user_id, p_refresh_token_id, p_ip_address, p_user_agent, p_device_name, p_expires_at
    )
    ON CONFLICT (id) DO UPDATE
    SET
        refresh_token_id = EXCLUDED.refresh_token_id,
        last_activity_at = NOW(),
        ip_address = EXCLUDED.ip_address,
        user_agent = EXCLUDED.user_agent;
END;
$$;

COMMENT ON FUNCTION security.session_save IS 'Saves a new session or updates existing one';
