-- =============================================
-- Tablo: messaging_log.message_delivery_logs
-- Mesaj gönderim detay logları
-- Worker tarafından yazılır
-- CLIENT_LOG DB - 90 gün retention
-- Günlük partition (created_at)
-- =============================================

DROP TABLE IF EXISTS messaging_log.message_delivery_logs CASCADE;

CREATE TABLE messaging_log.message_delivery_logs (
    id bigserial,

    campaign_id INTEGER NOT NULL,                 -- Kampanya ID (client DB referans)
    recipient_id BIGINT NOT NULL,                 -- Alıcı kaydı ID (client DB referans)
    player_id BIGINT NOT NULL,                    -- Oyuncu ID (client DB referans)

    -- Kanal ve durum
    channel_type VARCHAR(10) NOT NULL,            -- Kanal tipi: email, sms, local
    status VARCHAR(30) NOT NULL,                  -- Gönderim durumu
    -- queued: Kuyruğa alındı
    -- sending: Gönderiliyor
    -- sent: Gönderildi
    -- delivered: Teslim edildi
    -- failed: Başarısız
    -- bounced: Geri döndü (email)
    -- rejected: Reddedildi (provider)

    -- Hata bilgisi
    error_code VARCHAR(50),                       -- Hata kodu (provider'dan)
    error_message TEXT,                           -- Hata mesajı

    -- Provider yanıtı
    provider_name VARCHAR(50),                    -- Provider adı (sendgrid, twilio, vb.)
    provider_message_id VARCHAR(200),             -- Provider mesaj referans ID
    provider_response JSONB,                      -- Provider tam yanıtı

    -- Performans
    response_time_ms INTEGER,                     -- Yanıt süresi (milisaniye)

    created_at TIMESTAMP NOT NULL DEFAULT now(),
    PRIMARY KEY (id, created_at)                  -- Partition key PK'ya dahil
) PARTITION BY RANGE (created_at);

CREATE TABLE messaging_log.message_delivery_logs_default PARTITION OF messaging_log.message_delivery_logs DEFAULT;

COMMENT ON TABLE messaging_log.message_delivery_logs IS 'Detailed message delivery logs from worker service. Partitioned daily by created_at. Retention: 90 days.';
