-- =============================================
-- Player Documents (Oyuncu Belgeleri)
-- KYC için yüklenen belgeler
-- Dosyalar şifreli saklanır
-- =============================================

DROP TABLE IF EXISTS kyc.player_documents CASCADE;

CREATE TABLE kyc.player_documents (
    id BIGSERIAL PRIMARY KEY,

    player_id BIGINT NOT NULL,                    -- Oyuncu ID
    kyc_case_id BIGINT,                           -- Bağlı KYC vakası (opsiyonel)

    document_type VARCHAR(30) NOT NULL,           -- Belge tipi
    -- identity: Kimlik kartı
    -- passport: Pasaport
    -- driver_license: Ehliyet
    -- proof_of_address: Adres kanıtı (fatura vb.)
    -- selfie: Yüz fotoğrafı

    file_name VARCHAR(255),                       -- Dosya adı
    mime_type VARCHAR(50),                        -- Dosya tipi: image/jpeg, application/pdf

    storage_type VARCHAR(20) NOT NULL,            -- Depolama tipi
    -- db: Veritabanında BYTEA olarak
    -- object_storage: S3/MinIO/Azure Blob

    file_data BYTEA,                              -- Dosya verisi (DB storage için)
    storage_path VARCHAR(500),                    -- Depolama yolu (object storage için)

    encryption_key_id VARCHAR(100),               -- Şifreleme anahtarı ID

    file_hash BYTEA NOT NULL,                     -- Dosya hash (bütünlük kontrolü)
    file_size BIGINT NOT NULL,                    -- Dosya boyutu (byte)

    status VARCHAR(30) NOT NULL,                  -- Belge durumu
    -- uploaded: Yüklendi
    -- pending_review: İnceleme bekliyor
    -- approved: Onaylandı
    -- rejected: Reddedildi
    -- expired: Süresi doldu

    rejection_reason VARCHAR(255),                -- Red sebebi

    uploaded_at TIMESTAMP NOT NULL DEFAULT now(), -- Yükleme tarihi
    reviewed_at TIMESTAMP,                        -- İnceleme tarihi
    expires_at TIMESTAMP,                         -- Geçerlilik tarihi

    created_at TIMESTAMP NOT NULL DEFAULT now()
);

COMMENT ON TABLE kyc.player_documents IS 'KYC document uploads including identity cards, passports, and proof of address with encrypted storage';

