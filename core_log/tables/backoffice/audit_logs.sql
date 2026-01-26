-- =============================================
-- Tablo: backoffice.audit_logs
-- Açıklama: Genel denetim (audit) kayıtları
-- Sistem olaylarını ve değişiklikleri takip eder
-- =============================================

DROP TABLE IF EXISTS backoffice.audit_logs CASCADE;

CREATE TABLE IF NOT EXISTS backoffice.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),         -- Kaydın benzersiz kimliği
    event_id VARCHAR(255) NOT NULL,                        -- Olayın benzersiz kimliği
    original_event_id VARCHAR(255),                        -- Orijinal olayın kimliği
    tenant_id VARCHAR(100),                                -- Kiracı (Tenant) kimliği
    user_id VARCHAR(255),                                  -- İşlemi yapan kullanıcının kimliği
    action VARCHAR(100) NOT NULL,                          -- Gerçekleşen eylem veya aksiyon
    entity_type VARCHAR(100),                              -- Etkilenen varlığın türü
    entity_id VARCHAR(255),                                -- Etkilenen varlığın kimliği
    old_value JSONB,                                       -- Değişiklik öncesi eski değerler
    new_value JSONB,                                       -- Değişiklik sonrası yeni değerler
    ip_address VARCHAR(50),                                -- İşlemin yapıldığı IP adresi
    correlation_id VARCHAR(255),                           -- İşlem takibi için korelasyon kimliği
    forwarded_at TIMESTAMPTZ,                              -- Kaydın iletilme zamanı
    created_at TIMESTAMPTZ DEFAULT NOW()                   -- Kaydın oluşturulma zamanı
);

COMMENT ON TABLE backoffice.audit_logs IS 'Stores general audit logs for system events.';
