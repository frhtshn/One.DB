-- =============================================
-- Tablo: messaging.message_campaigns
-- Mesaj kampanyalarının ana tablosu
-- Kanal bazlı kampanya yönetimi ve zamanlaması
-- RabbitMQ üzerinden worker'a iletilir
-- =============================================

DROP TABLE IF EXISTS messaging.message_campaigns CASCADE;

CREATE TABLE messaging.message_campaigns (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,                   -- Kampanya adı (BO gösterimi)
    channel_type VARCHAR(10) NOT NULL,            -- Kanal tipi: email, sms, local
    template_id INTEGER,                          -- Bağlı şablon (opsiyonel - şablonsuz da olabilir)

    -- Durum
    status VARCHAR(20) NOT NULL DEFAULT 'draft',  -- Durum: draft, scheduled, processing, completed, failed, cancelled

    -- Zamanlama
    scheduled_at TIMESTAMP WITHOUT TIME ZONE,     -- Zamanlanmış gönderim zamanı (NULL = hemen)
    published_at TIMESTAMP WITHOUT TIME ZONE,     -- Operatör onay zamanı
    processing_started_at TIMESTAMP WITHOUT TIME ZONE, -- Worker işlemeye başladığı zaman
    completed_at TIMESTAMP WITHOUT TIME ZONE,     -- İşlem tamamlanma zamanı

    -- Özet istatistikler (worker tarafından güncellenir)
    total_recipients INTEGER NOT NULL DEFAULT 0,  -- Toplam alıcı sayısı
    sent_count INTEGER NOT NULL DEFAULT 0,        -- Başarılı gönderim sayısı
    failed_count INTEGER NOT NULL DEFAULT 0,      -- Başarısız gönderim sayısı

    -- Audit
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    updated_by INTEGER,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at TIMESTAMP WITHOUT TIME ZONE,
    deleted_by INTEGER
);

COMMENT ON TABLE messaging.message_campaigns IS 'Message campaigns with channel routing, scheduling, and delivery tracking for email, SMS, and local inbox';
