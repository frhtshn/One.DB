-- =============================================
-- Fonksiyon: security.auth_token_save
-- Aciklama: Token bilgisini kaydeder (upsert)
-- =============================================
DROP FUNCTION IF EXISTS security.auth_token_save(VARCHAR, VARCHAR, BIGINT, BIGINT, BIGINT, VARCHAR, SMALLINT, TEXT[], VARCHAR, VARCHAR, VARCHAR, JSONB, JSONB, TIMESTAMPTZ, TIMESTAMPTZ);
DROP FUNCTION IF EXISTS security.auth_token_save(VARCHAR, VARCHAR, BIGINT, BIGINT, BIGINT, VARCHAR, SMALLINT, TEXT[], VARCHAR, VARCHAR, VARCHAR, TEXT, TEXT, TIMESTAMPTZ, TIMESTAMPTZ);

CREATE OR REPLACE FUNCTION security.auth_token_save(
    p_token_hash VARCHAR(64),
    p_token_id VARCHAR(100),
    p_user_id BIGINT,
    p_company_id BIGINT DEFAULT NULL,
    p_client_id BIGINT DEFAULT NULL,
    p_session_id VARCHAR(50) DEFAULT NULL,
    p_token_type SMALLINT DEFAULT 1,
    p_global_roles TEXT[] DEFAULT '{}',
    p_ip_address VARCHAR(50) DEFAULT NULL,
    p_user_agent VARCHAR(500) DEFAULT NULL,
    p_device_id VARCHAR(100) DEFAULT NULL,
    p_metadata TEXT DEFAULT '{}',
    p_preferences TEXT DEFAULT '{}',
    p_created_at TIMESTAMPTZ DEFAULT NOW(),
    p_expires_at TIMESTAMPTZ DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO security.auth_tokens (
        token_hash, token_id, user_id, company_id, client_id,
        session_id, token_type, global_roles, ip_address, user_agent,
        device_id, metadata, preferences, created_at, expires_at
    ) VALUES (
        p_token_hash, p_token_id, p_user_id, p_company_id, p_client_id,
        p_session_id, p_token_type, p_global_roles, p_ip_address, p_user_agent,
        p_device_id, p_metadata::jsonb, p_preferences::jsonb, p_created_at, p_expires_at
    )
    ON CONFLICT (token_hash) DO UPDATE SET
        token_id = EXCLUDED.token_id,
        user_id = EXCLUDED.user_id,
        company_id = EXCLUDED.company_id,
        client_id = EXCLUDED.client_id,
        session_id = EXCLUDED.session_id,
        token_type = EXCLUDED.token_type,
        global_roles = EXCLUDED.global_roles,
        ip_address = EXCLUDED.ip_address,
        user_agent = EXCLUDED.user_agent,
        device_id = EXCLUDED.device_id,
        metadata = EXCLUDED.metadata,
        preferences = EXCLUDED.preferences,
        created_at = EXCLUDED.created_at,
        expires_at = EXCLUDED.expires_at;
END;
$$;
