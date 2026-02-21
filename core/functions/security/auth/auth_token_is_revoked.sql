-- =============================================
-- Fonksiyon: security.auth_token_is_revoked
-- Aciklama: Token'in iptal edilip edilmedigini kontrol eder
-- =============================================
DROP FUNCTION IF EXISTS security.auth_token_is_revoked(VARCHAR);

CREATE OR REPLACE FUNCTION security.auth_token_is_revoked(
    p_token_hash VARCHAR(64)
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_is_revoked BOOLEAN;
BEGIN
    SELECT t.is_revoked INTO v_is_revoked
    FROM security.auth_tokens t
    WHERE t.token_hash = p_token_hash;

    -- Kayit yoksa revoke degil (token hic persist edilmemis olabilir)
    RETURN COALESCE(v_is_revoked, FALSE);
END;
$$;
