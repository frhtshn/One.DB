-- =============================================
-- Tablo: logs.dead_letter_messages
-- Açıklama: İşlenemeyen mesajlar (Dead Letter)
-- Tekrar denenecek veya manuel çözülecek hatalı mesajlar
-- =============================================

DROP TABLE IF EXISTS logs.dead_letter_messages CASCADE;

CREATE TABLE logs.dead_letter_messages (
    id UUID DEFAULT gen_random_uuid(),                        -- Kayıt ID
    event_id VARCHAR(255) NOT NULL,                        -- Olay (Event) ID
    event_type VARCHAR(255) NOT NULL,                      -- Olay türü
    client_id VARCHAR(100),                                -- Client ID
    payload JSONB,                                         -- Mesaj içeriği (Payload)
    exception_message TEXT,                                -- Hata mesajı
    exception_stack_trace TEXT,                            -- Hata izi (Stack trace)
    retry_count INT DEFAULT 0,                             -- Otomatik retry sayısı
    status VARCHAR(50) DEFAULT 'pending',                  -- Durum
    created_at TIMESTAMPTZ DEFAULT NOW(),                  -- Oluşturulma zamanı
    updated_at TIMESTAMPTZ DEFAULT NOW(),                  -- Son güncellenme zamanı
    resolved_at TIMESTAMPTZ,                               -- Çözülme zamanı
    resolved_by VARCHAR(255),                              -- Çözümleyen kişi/sistem
    resolution_notes TEXT,                                 -- Çözüm notları
    cluster_id VARCHAR(50),                                -- Kaynak cluster (Core, BackOffice)
    consumer_name VARCHAR(255),                            -- Handler/consumer adı
    original_event_id VARCHAR(255),                        -- Orijinal event ID (retry tracking)
    manual_retry_count INT DEFAULT 0,                      -- Manuel retry sayısı
    failure_category VARCHAR(100),                         -- Hata kategorisi
    correlation_id VARCHAR(255),                           -- Korelasyon ID
    is_archived BOOLEAN DEFAULT FALSE,                     -- Arşivlenme durumu
    archived_at TIMESTAMPTZ,                               -- Arşivlenme zamanı
    next_retry_at TIMESTAMPTZ,                             -- Sonraki retry zamanı
    PRIMARY KEY (id, created_at)                           -- Partition key PK'ya dahil
) PARTITION BY RANGE (created_at);

CREATE TABLE logs.dead_letter_messages_default PARTITION OF logs.dead_letter_messages DEFAULT;

COMMENT ON TABLE logs.dead_letter_messages IS 'Stores failed messages for retry or manual resolution. Partitioned daily by created_at. Used by DeadLetterDataService, DeadLetterGrain.';
