-- =============================================
-- Tablo: game.game_sessions
-- Açıklama: Oyun oturumları
-- Provider callback'lerinde token → player çözümlemesi.
-- Game launch'ta oluşturulur, oturum bitiminde kapatılır.
-- =============================================

DROP TABLE IF EXISTS game.game_sessions CASCADE;

CREATE TABLE game.game_sessions (
    id BIGSERIAL PRIMARY KEY,

    -- Oturum tanımlayıcı
    session_token VARCHAR(100) NOT NULL,                                -- Provider'a iletilen benzersiz token (UUID)

    -- Oyuncu ve oyun bilgileri
    player_id BIGINT NOT NULL,                                         -- FK: auth.players
    provider_code VARCHAR(50) NOT NULL,                                -- PRAGMATIC, HUB88 vb.
    game_code VARCHAR(100) NOT NULL,                                   -- Internal game code
    external_game_id VARCHAR(100),                                     -- Provider'ın kendi game ID'si
    currency_code VARCHAR(20) NOT NULL,                                -- Oturumdaki para birimi

    -- Oturum durumu
    mode VARCHAR(20) NOT NULL DEFAULT 'real',                          -- real, demo, fun
    status VARCHAR(20) NOT NULL DEFAULT 'active',                      -- active, expired, closed

    -- İstemci bilgileri
    ip_address INET,                                                   -- Oyuncu IP'si
    device_type VARCHAR(20),                                           -- DESKTOP, MOBILE, APP
    user_agent VARCHAR(500),                                           -- Tarayıcı user-agent

    -- Provider bilgileri
    launch_url TEXT,                                                   -- Provider'dan dönen oyun URL'i
    metadata JSONB,                                                    -- Provider'a özgü launch parametreleri

    -- Zamanlama
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),                     -- Oturum oluşturulma zamanı
    expires_at TIMESTAMPTZ NOT NULL,                                   -- Oturum son geçerlilik zamanı
    last_activity_at TIMESTAMPTZ,                                      -- Son aktivite zamanı
    ended_at TIMESTAMPTZ,                                              -- Oturum bitiş zamanı
    ended_reason VARCHAR(50)                                           -- PLAYER_LOGOUT, TIMEOUT, PROVIDER_CLOSE, FORCED
);

COMMENT ON TABLE game.game_sessions IS 'Game session tracking for provider token-to-player resolution. Stores session lifecycle from launch to close/expire.';
