-- =============================================
-- Fonksiyon: security.auth_token_revoke
-- Aciklama: Token'i iptal edilmis olarak isaretler
-- =============================================
DROP FUNCTION IF EXISTS security.auth_token_revoke(VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION security.auth_token_revoke(
    p_token_hash VARCHAR(64),
    p_reason VARCHAR(200) DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE security.auth_tokens
    SET is_revoked = TRUE,
        revoked_at = NOW(),
        revoke_reason = p_reason
    WHERE token_hash = p_token_hash
      AND is_revoked = FALSE;
END;
$$;
