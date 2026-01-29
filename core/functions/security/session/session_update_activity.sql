-- ================================================================
-- SESSION_UPDATE_ACTIVITY: Session son aktivite zamanını güncelle
-- Açıklama: Refresh token kullanıldığında çağrılır.
-- ================================================================
CREATE OR REPLACE FUNCTION security.session_update_activity(
    p_session_id VARCHAR(50)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE security.user_sessions
    SET last_activity_at = NOW()
    WHERE id = p_session_id
      AND is_revoked = FALSE;

    -- Session bulunamazsa sessizce devam eder (hata döndürmez)
END;
$$;

COMMENT ON FUNCTION security.session_update_activity IS 'Updates session last activity timestamp';
