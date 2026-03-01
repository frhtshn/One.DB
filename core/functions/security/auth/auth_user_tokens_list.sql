-- =============================================
-- Fonksiyon: security.auth_user_tokens_list
-- Aciklama: Kullanicinin aktif token hash'lerini listeler
-- =============================================
DROP FUNCTION IF EXISTS security.auth_user_tokens_list(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION security.auth_user_tokens_list(
    p_user_id BIGINT,
    p_client_id BIGINT DEFAULT NULL
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
      AND (p_client_id IS NULL OR t.client_id = p_client_id);

    RETURN v_result;
END;
$$;
