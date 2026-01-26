-- ================================================================
-- PERMISSION_CLEANUP_EXPIRED - Süresi Dolmuş Override Temizliği
-- ================================================================

DROP FUNCTION IF EXISTS security.permission_cleanup_expired();

CREATE OR REPLACE FUNCTION security.permission_cleanup_expired()
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_deleted_count INT;
BEGIN
    DELETE FROM security.user_permission_overrides
    WHERE expires_at IS NOT NULL AND expires_at <= NOW();

    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
    RETURN v_deleted_count;
END;
$$;

COMMENT ON FUNCTION security.permission_cleanup_expired IS 'Cleans up expired permission overrides. Should be run as a scheduled job.';
