-- =============================================
-- Tablo: core.tenant_games
-- Açıklama: Tenant oyun etkinleştirme tablosu
-- Her tenant'in hangi oyunları sunacağını belirler
-- Tenant DB'deki game.game_settings ile senkronize edilir
-- =============================================

DROP TABLE IF EXISTS core.tenant_games CASCADE;

CREATE TABLE core.tenant_games (
    id BIGSERIAL PRIMARY KEY,                                       -- Benzersiz kayıt kimliği
    tenant_id BIGINT NOT NULL,                                      -- Tenant ID (FK: core.tenants)
    game_id BIGINT NOT NULL,                                        -- Oyun ID (FK: catalog.games)

    -- Etkinleştirme Durumu
    is_enabled BOOLEAN NOT NULL DEFAULT true,                       -- Oyun aktif mi
    enabled_at TIMESTAMP,                                           -- Aktifleştirme tarihi
    disabled_at TIMESTAMP,                                          -- Pasifleştirme tarihi
    disabled_reason VARCHAR(255),                                   -- Pasifleştirme nedeni

    -- Görünürlük Ayarları
    is_visible BOOLEAN NOT NULL DEFAULT true,                       -- Lobide görünür mü
    is_featured BOOLEAN NOT NULL DEFAULT false,                     -- Öne çıkarılmış mı
    display_order INTEGER DEFAULT 0,                                -- Sıralama

    -- Tenant Özelleştirmeleri
    custom_name VARCHAR(255),                                       -- Özel görünen ad
    custom_thumbnail_url VARCHAR(500),                              -- Özel thumbnail
    custom_categories VARCHAR(50)[] DEFAULT '{}',                   -- Tenant'a özel kategoriler
    custom_tags VARCHAR(50)[] DEFAULT '{}',                         -- Tenant'a özel etiketler

    -- RTP Override (Lisans gerektirebilir)
    rtp_variant VARCHAR(20),                                        -- RTP varyantı: DEFAULT, HIGH, LOW

    -- Platform Kısıtlamaları (Tenant seviyesinde)
    allowed_platforms VARCHAR(20)[] DEFAULT '{web,mobile,app}',     -- İzin verilen platformlar

    -- Coğrafi Kısıtlamalar (Tenant'a özel)
    blocked_countries CHAR(2)[] DEFAULT '{}',                       -- Engelli ülkeler (tenant override)
    allowed_countries CHAR(2)[] DEFAULT '{}',                       -- Sadece izin verilen ülkeler (boşsa tümü)

    -- Zamanlama
    available_from TIMESTAMP,                                       -- Ne zamandan itibaren mevcut
    available_until TIMESTAMP,                                      -- Ne zamana kadar mevcut

    -- Senkronizasyon
    sync_status VARCHAR(20) DEFAULT 'pending',                      -- Tenant DB senkronizasyon durumu: pending, synced, failed
    last_synced_at TIMESTAMP,                                       -- Son senkronizasyon tarihi

    -- Audit
    created_at TIMESTAMP NOT NULL DEFAULT now(),                    -- Kayıt oluşturma zamanı
    updated_at TIMESTAMP NOT NULL DEFAULT now(),                    -- Son güncelleme zamanı
    created_by BIGINT,                                              -- Oluşturan kullanıcı
    updated_by BIGINT                                               -- Güncelleyen kullanıcı
);

COMMENT ON TABLE core.tenant_games IS 'Tenant game enablement and customization. Defines which games from catalog are available for each tenant with custom settings.';
