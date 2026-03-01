-- =============================================
-- Tablo: core.client_games
-- Açıklama: Client oyun etkinleştirme tablosu
-- Her client'in hangi oyunları sunacağını belirler
-- Client DB'deki game.game_settings ile senkronize edilir
-- Denormalize alanlar: BO listesinde cross-DB JOIN yerine
-- doğrudan gösterilir (backend seed/sync sırasında doldurur)
-- game_id FK yok — catalog.games Game DB'de (cross-DB)
-- =============================================

DROP TABLE IF EXISTS core.client_games CASCADE;

CREATE TABLE core.client_games (
    id BIGSERIAL PRIMARY KEY,                                       -- Benzersiz kayıt kimliği
    client_id BIGINT NOT NULL,                                      -- Client ID (FK: core.clients)
    game_id BIGINT NOT NULL,                                        -- Oyun ID (Game DB — FK yok, cross-DB, backend doğrular)

    -- Denormalize Alanlar (Game DB'den — cross-DB JOIN yerine BO listesinde gösterilir)
    game_name VARCHAR(255),                                         -- Oyun görünen adı (Sweet Bonanza)
    game_code VARCHAR(100),                                         -- Normalize edilmiş oyun kodu (pragmatic_sweet_bonanza)
    provider_code VARCHAR(50),                                      -- Provider kodu (PRAGMATIC, EVOLUTION)
    game_type VARCHAR(50),                                          -- Ana tip: slot, live, table, crash
    thumbnail_url VARCHAR(500),                                     -- Küçük resim URL (lobby icon)

    -- Etkinleştirme Durumu
    is_enabled BOOLEAN NOT NULL DEFAULT true,                       -- Oyun aktif mi
    enabled_at TIMESTAMP,                                           -- Aktifleştirme tarihi
    disabled_at TIMESTAMP,                                          -- Pasifleştirme tarihi
    disabled_reason VARCHAR(255),                                   -- Pasifleştirme nedeni

    -- Görünürlük Ayarları
    is_visible BOOLEAN NOT NULL DEFAULT true,                       -- Lobide görünür mü
    is_featured BOOLEAN NOT NULL DEFAULT false,                     -- Öne çıkarılmış mı
    display_order INTEGER DEFAULT 0,                                -- Sıralama

    -- Client Özelleştirmeleri
    custom_name VARCHAR(255),                                       -- Özel görünen ad
    custom_thumbnail_url VARCHAR(500),                              -- Özel thumbnail
    custom_categories VARCHAR(50)[] DEFAULT '{}',                   -- Client'a özel kategoriler
    custom_tags VARCHAR(50)[] DEFAULT '{}',                         -- Client'a özel etiketler

    -- RTP Override (Lisans gerektirebilir)
    rtp_variant VARCHAR(20),                                        -- RTP varyantı: DEFAULT, HIGH, LOW

    -- Platform Kısıtlamaları (Client seviyesinde)
    allowed_platforms VARCHAR(20)[] DEFAULT '{web,mobile,app}',     -- İzin verilen platformlar

    -- Coğrafi Kısıtlamalar (Client'a özel)
    blocked_countries CHAR(2)[] DEFAULT '{}',                       -- Engelli ülkeler (client override)
    allowed_countries CHAR(2)[] DEFAULT '{}',                       -- Sadece izin verilen ülkeler (boşsa tümü)

    -- Zamanlama
    available_from TIMESTAMP,                                       -- Ne zamandan itibaren mevcut
    available_until TIMESTAMP,                                      -- Ne zamana kadar mevcut

    -- Senkronizasyon
    sync_status VARCHAR(20) DEFAULT 'pending',                      -- Client DB senkronizasyon durumu: pending, synced, failed
    last_synced_at TIMESTAMP,                                       -- Son senkronizasyon tarihi

    -- Audit
    created_at TIMESTAMP NOT NULL DEFAULT now(),                    -- Kayıt oluşturma zamanı
    updated_at TIMESTAMP NOT NULL DEFAULT now(),                    -- Son güncelleme zamanı
    created_by BIGINT,                                              -- Oluşturan kullanıcı
    updated_by BIGINT                                               -- Güncelleyen kullanıcı
);

COMMENT ON TABLE core.client_games IS 'Client game enablement and customization. Denormalized fields from Game DB catalog for cross-DB BO listing without JOINs. game_id has no FK (cross-DB, backend validates).';
