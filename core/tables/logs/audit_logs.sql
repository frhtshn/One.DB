-- =============================================
-- Tablo: logs.audit_logs
-- Açıklama: Core kümesi denetim (audit) kayıtları
-- Core cluster üzerindeki eylemleri takip eder
-- =============================================

DROP TABLE IF EXISTS logs.audit_logs CASCADE;

CREATE TABLE logs.audit_logs (
    id UUID DEFAULT gen_random_uuid(),                        -- Kaydın benzersiz kimliği
    event_id VARCHAR(255) NOT NULL,                        -- Olayın benzersiz kimliği
    user_id VARCHAR(255),                                  -- İşlemi yapan kullanıcının kimliği
    action VARCHAR(100) NOT NULL,                          -- Gerçekleşen eylem
    entity_type VARCHAR(100),                              -- Etkilenen varlık türü
    entity_id VARCHAR(255),                                -- Etkilenen varlık kimliği
    old_value JSONB,                                       -- Değişiklik öncesi eski değer
    new_value JSONB,                                       -- Değişiklik sonrası yeni değer
    ip_address VARCHAR(50),                                -- IP adresi
    correlation_id VARCHAR(255),                           -- Korelasyon kimliği
    created_at TIMESTAMPTZ DEFAULT NOW(),                  -- Oluşturulma zamanı
    PRIMARY KEY (id, created_at)                                 -- Partition key PK'ya dahil
) PARTITION BY RANGE (created_at);

CREATE TABLE logs.audit_logs_default PARTITION OF logs.audit_logs DEFAULT;

COMMENT ON TABLE logs.audit_logs IS 'Stores audit trail for Core cluster actions. Partitioned daily by created_at. Used by CoreAuditDataService, CoreAuditConsumer.';
