-- =============================================
-- Tablo: messaging.player_message_preferences
-- Oyuncu mesaj kanal tercihleri
-- Her kanal için opt-in/opt-out ayarı
-- =============================================

DROP TABLE IF EXISTS messaging.player_message_preferences CASCADE;

CREATE TABLE messaging.player_message_preferences (
    id BIGSERIAL PRIMARY KEY,
    player_id BIGINT NOT NULL,                    -- Oyuncu ID
    channel_type VARCHAR(10) NOT NULL,            -- Kanal tipi: email, sms, local
    is_opted_in BOOLEAN NOT NULL DEFAULT TRUE,    -- Kabul etti mi? (TRUE = mesaj gönder)
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now()
);

COMMENT ON TABLE messaging.player_message_preferences IS 'Player messaging channel preferences for opt-in/opt-out per channel type (email, SMS, local)';
