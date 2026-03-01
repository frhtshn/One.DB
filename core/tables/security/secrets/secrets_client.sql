-- =============================================
-- Tablo: security.secrets_client
-- Açıklama: Client gizli bilgileri (secrets)
-- Client bazında API key, JWT secret gibi hassas bilgiler
-- Farklı ortamlar (prod, staging) için ayrı kayıtlar tutulabilir
-- =============================================

DROP TABLE IF EXISTS security.secrets_client CASCADE;

CREATE TABLE security.secrets_client (
    id bigserial PRIMARY KEY,                              -- Benzersiz secret kimliği
    client_id bigint NOT NULL,                             -- Client ID (FK: core.clients)
    secret_type varchar(50) NOT NULL,                      -- Secret tipi: JWT_SECRET, ENCRYPTION_KEY
    secret_value text NOT NULL,                            -- Şifreli secret değeri
    environment varchar(20) NOT NULL DEFAULT 'production', -- Ortam: production, staging, shadow
    is_active boolean NOT NULL DEFAULT true,               -- Aktif/pasif durumu
    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    rotated_at timestamp without time zone                 -- Son anahtar rotasyon zamanı
);

COMMENT ON TABLE security.secrets_client IS 'Client secrets storage for sensitive credentials like JWT secrets and encryption keys, supporting multiple environments';
