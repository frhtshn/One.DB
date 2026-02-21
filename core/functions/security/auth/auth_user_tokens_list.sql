-- =============================================
-- Fonksiyon: security.auth_user_tokens_list
-- Aciklama: Kullanicinin aktif token hash'lerini listeler
-- =============================================
DROP FUNCTION IF EXISTS security.auth_user_tokens_list(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION security.auth_user_tokens_list(
    p_user_id BIGINT,
    p_tenant_id BIGINT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT COALESCE(jsonb_agg(t.token_hash), '[]'::jsonb) INTO v_result
    FROM security.auth_tokens t
    WHERE t.user_id = p_user_id
      AND t.is_revoked = FALSE
      AND t.expires_at > NOW()
      AND (p_tenant_id IS NULL OR t.tenant_id = p_tenant_id);

    RETURN v_result;
END;
$$;
