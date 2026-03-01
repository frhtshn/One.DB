-- =============================================
-- Tablo: security.user_allowed_clients
-- Açıklama: Platform Rol Client Kısıtlaması
-- Platform kullanıcılarının hangi clientlara erişebileceğini belirler
-- =============================================

DROP TABLE IF EXISTS security.user_allowed_clients CASCADE;

CREATE TABLE security.user_allowed_clients (
    user_id BIGINT NOT NULL,                               -- Kullanıcı ID (FK: security.users)
    client_id BIGINT NOT NULL,                             -- Client ID (FK: core.clients)
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),         -- Oluşturulma zamanı
    created_by BIGINT,                                     -- Oluşturan kullanıcı (FK: security.users)

    PRIMARY KEY (user_id, client_id)
);

COMMENT ON TABLE security.user_allowed_clients IS 'Restricts platform users to specific clients. Empty means access to all (superadmin mode).';
