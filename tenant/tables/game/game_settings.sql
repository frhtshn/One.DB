-- =============================================
-- Game Settings (Oyun Ayarları)
-- Tenant'ın kullandığı oyunlar ve özelleştirmeleri
-- Core DB'den denormalize edilmiş + tenant override'ları
-- =============================================

DROP TABLE IF EXISTS game.game_settings CASCADE;

CREATE TABLE game.game_settings (
    id bigserial PRIMARY KEY,

    -- Core DB'den denormalize edilmiş alanlar (catalog.games + catalog.providers)
    game_id bigint NOT NULL,                      -- Core DB'deki oyun ID
    game_code varchar(100) NOT NULL,              -- Oyun kodu: sweet_bonanza, gates_of_olympus
    game_name varchar(255) NOT NULL,              -- Oyun adı
    provider_id bigint NOT NULL,                  -- Provider ID (Pragmatic, NetEnt vb.)
    provider_code varchar(50) NOT NULL,           -- Provider kodu

    -- Tenant'a özel görünüm ayarları
    display_order int,                            -- Sıralama
    is_visible boolean NOT NULL DEFAULT true,     -- Lobide görünsün mü?
    is_active boolean NOT NULL DEFAULT true,      -- Oynanabilir mi?
    is_featured boolean NOT NULL DEFAULT false,   -- Öne çıkarılsın mı?

    -- Tenant'a özel özelleştirmeler
    custom_name varchar(255),                     -- Özel oyun adı
    custom_thumbnail_url varchar(500),            -- Özel küçük resim URL

    -- Ek metadata
    tags jsonb,                                   -- Etiketler: ["new", "popular", "jackpot"]
    metadata jsonb,                               -- Ek bilgiler

    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);

COMMENT ON TABLE game.game_settings IS 'Tenant game configurations with display settings, custom branding, and bet limits per game';
