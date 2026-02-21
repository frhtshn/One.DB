-- =============================================
-- Fonksiyon: security.auth_token_get
-- Aciklama: Token bilgisini hash ile okur
-- =============================================
DROP FUNCTION IF EXISTS security.auth_token_get(VARCHAR);

CREATE OR REPLACE FUNCTION security.auth_token_get(
    p_token_hash VARCHAR(64)
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'tokenId', t.token_id,
        'userId', t.user_id,
        'companyId', t.company_id,
        'tenantId', t.tenant_id,
        'sessionId', t.session_id,
        'type', t.token_type,
        'globalRoles', to_jsonb(t.global_roles),
        'ipAddress', t.ip_address,
        'userAgent', t.user_agent,
        'deviceId', t.device_id,
        'metadata', t.metadata,
        'preferences', t.preferences,
        'createdAt', t.created_at,
        'expiresAt', t.expires_at
    ) INTO v_result
    FROM security.auth_tokens t
    WHERE t.token_hash = p_token_hash
      AND t.is_revoked = FALSE
      AND t.expires_at > NOW();

    RETURN v_result;
END;
$$;
