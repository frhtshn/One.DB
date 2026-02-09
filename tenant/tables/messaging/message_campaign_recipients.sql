-- =============================================
-- Tablo: messaging.message_campaign_recipients
-- Kampanya alıcı listesi (segment çözümlemesi sonrası)
-- Worker tarafından işlenir ve durum güncellenir
-- =============================================

DROP TABLE IF EXISTS messaging.message_campaign_recipients CASCADE;

CREATE TABLE messaging.message_campaign_recipients (
    id BIGSERIAL PRIMARY KEY,
    campaign_id INTEGER NOT NULL,                 -- Bağlı kampanya
    player_id BIGINT NOT NULL,                    -- Alıcı oyuncu ID

    -- Gönderim durumu
    status VARCHAR(20) NOT NULL DEFAULT 'pending', -- Durum: pending, sent, failed, delivered, opened, clicked
    language_code CHAR(2),                        -- Oyuncunun tercih ettiği dil (gönderim için)

    -- Gönderim zamanları (worker günceller)
    sent_at TIMESTAMP WITHOUT TIME ZONE,          -- Gönderim zamanı
    delivered_at TIMESTAMP WITHOUT TIME ZONE,     -- Teslim zamanı (provider callback)
    opened_at TIMESTAMP WITHOUT TIME ZONE,        -- Açılma zamanı (tracking pixel/webhook)
    clicked_at TIMESTAMP WITHOUT TIME ZONE,       -- Tıklama zamanı

    -- Hata bilgisi
    error_message TEXT,                           -- Hata mesajı (başarısız gönderimde)

    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now()
);

COMMENT ON TABLE messaging.message_campaign_recipients IS 'Resolved campaign recipient list after segment evaluation with per-recipient delivery status tracking';
