-- =============================================
-- Fonksiyon: security.auth_token_delete
-- Aciklama: Token'i siler
-- =============================================
DROP FUNCTION IF EXISTS security.auth_token_delete(VARCHAR);

CREATE OR REPLACE FUNCTION security.auth_token_delete(
    p_token_hash VARCHAR(64)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM security.auth_tokens
    WHERE token_hash = p_token_hash;
END;
$$;
