-- =============================================
-- Tablo: backoffice_log.audit_logs
-- Açıklama: Genel denetim (audit) kayıtları
-- Sistem olaylarını ve değişiklikleri takip eder
-- =============================================

DROP TABLE IF EXISTS backoffice_log.audit_logs CASCADE;

CREATE TABLE backoffice_log.audit_logs (
    id UUID DEFAULT gen_random_uuid(),                        -- Kaydın benzersiz kimliği
    event_id VARCHAR(255) NOT NULL,                        -- Olayın benzersiz kimliği
    original_event_id VARCHAR(255),                        -- Orijinal olayın kimliği
    client_id VARCHAR(100),                                -- Client kimliği
    user_id VARCHAR(255),                                  -- İşlemi yapan kullanıcının kimliği
    action VARCHAR(100) NOT NULL,                          -- Gerçekleşen eylem veya aksiyon
    entity_type VARCHAR(100),                              -- Etkilenen varlığın türü
    entity_id VARCHAR(255),                                -- Etkilenen varlığın kimliği
    old_value JSONB,                                       -- Değişiklik öncesi eski değerler
    new_value JSONB,                                       -- Değişiklik sonrası yeni değerler
    ip_address VARCHAR(50),                                -- İşlemin yapıldığı IP adresi
    correlation_id VARCHAR(255),                           -- İşlem takibi için korelasyon kimliği
    forwarded_at TIMESTAMPTZ,                              -- Kaydın iletilme zamanı
    created_at TIMESTAMPTZ DEFAULT NOW(),                  -- Kaydın oluşturulma zamanı
    PRIMARY KEY (id, created_at)                                 -- Partition key PK'ya dahil
) PARTITION BY RANGE (created_at);

CREATE TABLE backoffice_log.audit_logs_default PARTITION OF backoffice_log.audit_logs DEFAULT;

COMMENT ON TABLE backoffice_log.audit_logs IS 'Stores general audit logs for system events. Partitioned daily by created_at.';
