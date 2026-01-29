-- =============================================
-- Tablo: logs.dead_letter_messages
-- Açıklama: İşlenemeyen mesajlar (Dead Letter)
-- Tekrar denenecek veya manuel çözülecek hatalı mesajlar
-- =============================================

DROP TABLE IF EXISTS logs.dead_letter_messages CASCADE;

CREATE TABLE IF NOT EXISTS logs.dead_letter_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),         -- Kayıt ID
    event_id VARCHAR(255) NOT NULL,                        -- Olay (Event) ID
    event_type VARCHAR(255) NOT NULL,                      -- Olay türü
    tenant_id VARCHAR(100),                                -- Tenant ID
    payload JSONB,                                         -- Mesaj içeriği (Payload)
    exception_message TEXT,                                -- Hata mesajı
    exception_stack_trace TEXT,                            -- Hata izi (Stack trace)
    retry_count INT DEFAULT 0,                             -- Tekrar deneme sayısı
    status VARCHAR(50) DEFAULT 'pending',                  -- Durum: pending, retrying, resolved, failed
    created_at TIMESTAMPTZ DEFAULT NOW(),                  -- Oluşturulma zamanı
    updated_at TIMESTAMPTZ DEFAULT NOW(),                  -- Son güncellenme zamanı
    resolved_at TIMESTAMPTZ,                               -- Çözülme zamanı
    resolved_by VARCHAR(255),                              -- Çözümleyen kişi/sistem
    resolution_notes TEXT                                  -- Çözüm notları

);

COMMENT ON TABLE logs.dead_letter_messages IS 'Stores failed messages for retry or manual resolution. Used by DeadLetterDataService, DeadLetterGrain.';
