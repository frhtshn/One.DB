-- =============================================
-- Tablo: security.auth_tokens
-- Aciklama: Token persistence (Redis fallback)
-- Redis down senaryosunda token bilgisi buradan okunur.
-- SHA-256 token hash ile PK.
-- =============================================

DROP TABLE IF EXISTS security.auth_tokens CASCADE;

CREATE TABLE security.auth_tokens (
    token_hash VARCHAR(64) NOT NULL,                              -- SHA-256 hex hash of opaque token
    token_id VARCHAR(100) NOT NULL,                               -- Token benzersiz kimligi (jti)
    user_id BIGINT NOT NULL,                                      -- Kullanici ID
    company_id BIGINT,                                            -- Company ID (nullable)
    client_id BIGINT,                                             -- Client ID (nullable)
    session_id VARCHAR(50) NOT NULL,                              -- Session ID
    token_type SMALLINT NOT NULL DEFAULT 1,                       -- 1=Access, 2=Refresh (C# TokenType enum)
    global_roles TEXT[] NOT NULL DEFAULT '{}',                    -- Global roller
    ip_address VARCHAR(50),                                       -- Olusturulma IP
    user_agent VARCHAR(500),                                      -- User agent
    device_id VARCHAR(100),                                       -- Cihaz ID
    metadata JSONB NOT NULL DEFAULT '{}',                         -- Ek metadata
    preferences JSONB NOT NULL DEFAULT '{}',                      -- Kullanici tercihleri
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),                -- Olusturulma zamani
    expires_at TIMESTAMPTZ NOT NULL,                              -- Bitis zamani
    is_revoked BOOLEAN NOT NULL DEFAULT FALSE,                    -- Iptal edildi mi
    revoked_at TIMESTAMPTZ,                                       -- Iptal zamani
    revoke_reason VARCHAR(200),                                   -- Iptal nedeni
    PRIMARY KEY (token_hash)
);

COMMENT ON TABLE security.auth_tokens IS 'Token persistence for Redis fallback. SHA-256 hashed opaque tokens.';
