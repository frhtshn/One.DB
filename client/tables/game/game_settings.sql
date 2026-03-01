-- =============================================
-- Tablo: game.game_settings
-- Açıklama: Client oyun ayarları
-- Core DB'den denormalize edilmiş oyun bilgileri + client özelleştirmeleri
-- catalog.games + core.client_games verilerinin client kopyası
-- =============================================

DROP TABLE IF EXISTS game.game_settings CASCADE;

CREATE TABLE game.game_settings (
    id BIGSERIAL PRIMARY KEY,

    -- Core DB Referansları
    game_id BIGINT NOT NULL,                                        -- Core DB'deki oyun ID (catalog.games.id)
    provider_id BIGINT NOT NULL,                                    -- Provider ID (catalog.providers.id)

    -- Denormalize Edilmiş Oyun Bilgileri (catalog.games'den)
    external_game_id VARCHAR(100) NOT NULL,                         -- Provider'ın oyun ID'si
    game_code VARCHAR(100) NOT NULL,                                -- Normalize edilmiş oyun kodu
    game_name VARCHAR(255) NOT NULL,                                -- Oyun görünen adı
    provider_code VARCHAR(50) NOT NULL,                             -- Provider kodu
    studio VARCHAR(100),                                            -- Oyun stüdyosu

    -- Kategorilendirme (catalog.games'den)
    game_type VARCHAR(50) NOT NULL DEFAULT 'SLOT',                  -- Ana tip: SLOT, LIVE, TABLE, CRASH
    game_subtype VARCHAR(50),                                       -- Alt tip: VIDEO_SLOT, MEGAWAYS, BLACKJACK
    categories VARCHAR(50)[] DEFAULT '{}',                          -- Kategoriler: popular, new, hot
    tags VARCHAR(50)[] DEFAULT '{}',                                -- Etiketler: fruits, egypt, asian

    -- Oyun Mekanikleri (catalog.games'den)
    rtp DECIMAL(5,2),                                               -- Return to Player yüzdesi
    volatility VARCHAR(20),                                         -- Volatilite: LOW, MEDIUM, HIGH
    max_multiplier DECIMAL(10,2),                                   -- Maksimum çarpan
    paylines INTEGER,                                               -- Ödeme çizgi sayısı

    -- Görseller (catalog.games'den veya client override)
    thumbnail_url VARCHAR(500),                                     -- Küçük resim URL
    background_url VARCHAR(500),                                    -- Arka plan resim URL
    logo_url VARCHAR(500),                                          -- Oyun logo URL

    -- Özellikler (catalog.games'den)
    features VARCHAR(50)[] DEFAULT '{}',                            -- Özellikler: FREESPINS, MULTIPLIER, BONUS_BUY
    has_demo BOOLEAN NOT NULL DEFAULT true,                         -- Demo modu var mı
    has_jackpot BOOLEAN NOT NULL DEFAULT false,                     -- Jackpot oyunu mu
    jackpot_type VARCHAR(50),                                       -- Jackpot tipi: LOCAL, NETWORK, PROGRESSIVE
    has_bonus_buy BOOLEAN NOT NULL DEFAULT false,                   -- Bonus satın alma özelliği

    -- Platform Desteği (catalog.games'den)
    is_mobile BOOLEAN NOT NULL DEFAULT true,                        -- Mobil uyumlu mu
    is_desktop BOOLEAN NOT NULL DEFAULT true,                       -- Desktop uyumlu mu

    -- Client Görünüm Ayarları (core.client_games override)
    display_order INTEGER DEFAULT 0,                                -- Sıralama
    is_visible BOOLEAN NOT NULL DEFAULT true,                       -- Lobide görünsün mü
    is_enabled BOOLEAN NOT NULL DEFAULT true,                       -- Oynanabilir mi
    is_featured BOOLEAN NOT NULL DEFAULT false,                     -- Öne çıkarılsın mı

    -- Client Özelleştirmeleri (core.client_games override)
    custom_name VARCHAR(255),                                       -- Özel oyun adı
    custom_thumbnail_url VARCHAR(500),                              -- Özel küçük resim URL
    custom_categories VARCHAR(50)[] DEFAULT '{}',                   -- Client'a özel kategoriler
    custom_tags VARCHAR(50)[] DEFAULT '{}',                         -- Client'a özel etiketler

    -- RTP Varyantı
    rtp_variant VARCHAR(20),                                        -- RTP varyantı: DEFAULT, HIGH, LOW

    -- Platform Kısıtlamaları (Client override)
    allowed_platforms VARCHAR(20)[] DEFAULT '{WEB,MOBILE,APP}',     -- İzin verilen platformlar

    -- Coğrafi Kısıtlamalar (Client override)
    blocked_countries CHAR(2)[] DEFAULT '{}',                       -- Engelli ülkeler
    allowed_countries CHAR(2)[] DEFAULT '{}',                       -- Sadece izin verilen ülkeler (boşsa tümü)

    -- Shadow Mode (SHADOW_MODE — provider rollout status miras alınır)
    rollout_status VARCHAR(20) NOT NULL DEFAULT 'production',       -- shadow: sadece test oyuncuları, production: herkes

    -- Zamanlama
    available_from TIMESTAMP,                                       -- Ne zamandan itibaren mevcut
    available_until TIMESTAMP,                                      -- Ne zamana kadar mevcut

    -- Popülerlik (Hesaplanan)
    popularity_score INTEGER DEFAULT 0,                             -- Popülerlik puanı
    play_count BIGINT DEFAULT 0,                                    -- Toplam oynanma sayısı

    -- Senkronizasyon
    core_synced_at TIMESTAMP,                                       -- Core DB'den son sync tarihi

    -- Audit
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now()
);

COMMENT ON TABLE game.game_settings IS 'Client game configurations with denormalized game data from core, display settings, custom branding, and platform restrictions';
