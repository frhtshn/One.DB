-- =============================================
-- Tablo: logs.dead_letter_messages
-- Aciklama: Islenemeyen mesajlar (Dead Letter)
-- Tekrar denenecek veya manuel cozulecek hatali mesajlar
-- =============================================

DROP TABLE IF EXISTS logs.dead_letter_messages CASCADE;

CREATE TABLE logs.dead_letter_messages (
    id UUID DEFAULT gen_random_uuid(),                        -- Kayit ID
    event_id VARCHAR(255) NOT NULL,                        -- Olay (Event) ID
    event_type VARCHAR(255) NOT NULL,                      -- Olay turu
    tenant_id VARCHAR(100),                                -- Tenant ID
    payload JSONB,                                         -- Mesaj icerigi (Payload)
    exception_message TEXT,                                -- Hata mesaji
    exception_stack_trace TEXT,                            -- Hata izi (Stack trace)
    retry_count INT DEFAULT 0,                             -- Otomatik retry sayisi
    status VARCHAR(50) DEFAULT 'pending',                  -- Durum
    created_at TIMESTAMPTZ DEFAULT NOW(),                  -- Olusturulma zamani
    updated_at TIMESTAMPTZ DEFAULT NOW(),                  -- Son guncellenme zamani
    resolved_at TIMESTAMPTZ,                               -- Cozulme zamani
    resolved_by VARCHAR(255),                              -- Cozumleyen kisi/sistem
    resolution_notes TEXT,                                 -- Cozum notlari
    cluster_id VARCHAR(50),                                -- Kaynak cluster (Core, BackOffice)
    consumer_name VARCHAR(255),                            -- Handler/consumer adi
    original_event_id VARCHAR(255),                        -- Orijinal event ID (retry tracking)
    manual_retry_count INT DEFAULT 0,                      -- Manuel retry sayisi
    failure_category VARCHAR(100),                         -- Hata kategorisi
    correlation_id VARCHAR(255),                           -- Korelasyon ID
    is_archived BOOLEAN DEFAULT FALSE,                     -- Arsivlenme durumu
    archived_at TIMESTAMPTZ,                               -- Arsivlenme zamani
    next_retry_at TIMESTAMPTZ,                             -- Sonraki retry zamani
    PRIMARY KEY (id, created_at)                           -- Partition key PK'ya dahil
) PARTITION BY RANGE (created_at);

CREATE TABLE logs.dead_letter_messages_default PARTITION OF logs.dead_letter_messages DEFAULT;

COMMENT ON TABLE logs.dead_letter_messages IS 'Stores failed messages for retry or manual resolution. Partitioned daily by created_at. Used by DeadLetterDataService, DeadLetterGrain.';
