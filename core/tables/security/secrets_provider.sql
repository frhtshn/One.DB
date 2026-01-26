-- =============================================
-- Tablo: security.secrets_provider
-- Açıklama: Provider gizli bilgileri (secrets)
-- API key, secret key gibi hassas bilgilerin saklandığı tablo
-- Değerler şifreli olarak tutulmalıdır (uygulama katmanında)
-- =============================================

DROP TABLE IF EXISTS security.secrets_provider CASCADE;

CREATE TABLE security.secrets_provider (
    id bigserial PRIMARY KEY,                              -- Benzersiz secret kimliği
    provider_id bigint NOT NULL,                           -- Provider ID (FK: catalog.providers)
    secret_type varchar(50) NOT NULL,                      -- Secret tipi: API_KEY, SECRET_KEY, WEBHOOK_SECRET
    secret_value text NOT NULL,                            -- Şifreli secret değeri
    is_active boolean NOT NULL DEFAULT true,               -- Aktif/pasif durumu
    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    rotated_at timestamp without time zone                 -- Son anahtar rotasyon zamanı
);
