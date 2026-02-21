-- =============================================
-- Fonksiyon: security.auth_token_cleanup
-- Aciklama: Expire olmus token kayitlarini temizler.
--   Revoked token'lar expires_at'e kadar is_revoked ile korunur,
--   expire olduktan sonra bu job siler.
-- =============================================
DROP FUNCTION IF EXISTS security.auth_token_cleanup(INTEGER);
DROP FUNCTION IF EXISTS security.auth_token_cleanup();

CREATE OR REPLACE FUNCTION security.auth_token_cleanup()
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_deleted BIGINT;
BEGIN
    DELETE FROM security.auth_tokens
    WHERE expires_at < NOW();

    GET DIAGNOSTICS v_deleted = ROW_COUNT;
    RETURN v_deleted;
END;
$$;
