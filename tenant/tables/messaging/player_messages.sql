-- =============================================
-- Tablo: messaging.player_messages
-- Oyuncu yerel mesaj kutusu (inbox)
-- Kampanya veya sistem mesajları için
-- Aylık partition (created_at) - retention: 180 gün
-- Oyuncu tarafından okunma ve silinme (soft delete)
-- =============================================

DROP TABLE IF EXISTS messaging.player_messages CASCADE;

CREATE TABLE messaging.player_messages (
    id bigserial,
    player_id BIGINT NOT NULL,                    -- Alıcı oyuncu ID
    campaign_id INTEGER,                          -- Bağlı kampanya (NULL = sistem mesajı)

    -- İçerik (oyuncunun diline göre çözümlenmiş)
    subject VARCHAR(500) NOT NULL,                -- Mesaj konusu
    body TEXT NOT NULL,                            -- Mesaj içeriği (HTML)
    message_type VARCHAR(30) NOT NULL DEFAULT 'campaign', -- Mesaj tipi: campaign, system, welcome, kyc, transaction

    -- Okunma durumu
    is_read BOOLEAN NOT NULL DEFAULT FALSE,       -- Okundu mu?
    read_at TIMESTAMP WITHOUT TIME ZONE,          -- Okunma zamanı

    -- Oyuncu perspektifinden soft delete
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,    -- Oyuncu sildi mi?
    deleted_at TIMESTAMP WITHOUT TIME ZONE,       -- Silinme zamanı

    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),

    PRIMARY KEY (id, created_at)                  -- Partition key PK'ya dahil
) PARTITION BY RANGE (created_at);

CREATE TABLE messaging.player_messages_default PARTITION OF messaging.player_messages DEFAULT;

COMMENT ON TABLE messaging.player_messages IS 'Player local inbox for campaign and system messages. Partitioned monthly by created_at. Retention: 180 days.';

-- message_type değerleri:
-- campaign: Kampanya mesajı (BO tarafından gönderildi)
-- system: Sistem bildirimi (otomatik)
-- welcome: Hoşgeldin mesajı
-- kyc: KYC bildirim mesajı
-- transaction: İşlem bildirim mesajı
