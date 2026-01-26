-- =============================================
-- Tablo: security.user_sessions
-- Açıklama: Aktif Oturumlar
-- Kullanıcıların aktif oturum bilgilerini tutar
-- =============================================

DROP TABLE IF EXISTS security.user_sessions CASCADE;

CREATE TABLE security.user_sessions (
    id VARCHAR(50) PRIMARY KEY,                            -- Oturum ID (Session ID)
    user_id BIGINT NOT NULL REFERENCES security.users(id) ON DELETE CASCADE, -- Kullanıcı ID
    refresh_token_id VARCHAR(100) NOT NULL,                -- Refresh token ID
    ip_address VARCHAR(50),                                -- IP adresi
    user_agent VARCHAR(500),                               -- User Agent
    device_name VARCHAR(100),                              -- Cihaz adı
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),         -- Oluşturulma zamanı
    last_activity_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),   -- Son aktivite zamanı
    expires_at TIMESTAMPTZ NOT NULL,                       -- Geçerlilik bitiş zamanı
    is_revoked BOOLEAN NOT NULL DEFAULT FALSE,             -- İptal edildi mi?
    revoked_at TIMESTAMPTZ,                                -- İptal zamanı
    revoke_reason VARCHAR(200)                             -- İptal nedeni
);

COMMENT ON TABLE security.user_sessions IS 'Active user sessions tracking';
