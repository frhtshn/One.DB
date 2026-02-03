-- =============================================
-- Tablo: catalog.games
-- Açıklama: Oyun kataloğu
-- Tüm provider'lardan gelen oyunların merkezi listesi
-- Her oyun tek bir provider'a bağlıdır
-- Provider API'lerinden senkronize edilir
-- =============================================

DROP TABLE IF EXISTS catalog.games CASCADE;

CREATE TABLE catalog.games (
    -- Kimlik
    id BIGSERIAL PRIMARY KEY,                                       -- Dahili benzersiz oyun kimliği
    provider_id BIGINT NOT NULL,                                    -- Oyun sağlayıcı ID (FK: catalog.providers)
    external_game_id VARCHAR(100) NOT NULL,                         -- Provider'ın kendi oyun ID'si (API'den gelen)
    game_code VARCHAR(100) NOT NULL,                                -- Normalize edilmiş oyun kodu (pragmatic_sweet_bonanza)

    -- Temel Bilgiler
    game_name VARCHAR(255) NOT NULL,                                -- Oyun görünen adı (Sweet Bonanza)
    studio VARCHAR(100),                                            -- Oyun stüdyosu/yapımcı (Pragmatic Play, Evolution)
    description TEXT,                                               -- Oyun açıklaması

    -- Kategorilendirme
    game_type VARCHAR(50) NOT NULL DEFAULT 'slot',                  -- Ana tip: slot, live, table, crash, scratch, bingo, virtual
    game_subtype VARCHAR(50),                                       -- Alt tip: VIDEO_SLOT, MEGAWAYS, CLASSIC, BLACKJACK, ROULETTE, BACCARAT
    categories VARCHAR(50)[] DEFAULT '{}',                          -- Kategoriler: popular, new, hot, jackpot, bonus_buy
    tags VARCHAR(50)[] DEFAULT '{}',                                -- Etiketler: fruits, egypt, asian, adventure

    -- Oyun Mekanikleri
    rtp DECIMAL(5,2),                                               -- Return to Player yüzdesi (96.51)
    volatility VARCHAR(20),                                         -- Volatilite: LOW, MEDIUM, MEDIUM_HIGH, HIGH, VERY_HIGH
    hit_frequency DECIMAL(5,2),                                     -- Kazanma sıklığı yüzdesi
    max_multiplier DECIMAL(10,2),                                   -- Maksimum çarpan (x5000)
    paylines INTEGER,                                               -- Ödeme çizgi sayısı (20, 243, 117649)
    reels INTEGER,                                                  -- Makara sayısı (5, 6, 7)
    rows INTEGER,                                                   -- Satır sayısı (3, 4, 5)

    -- Görseller
    thumbnail_url VARCHAR(500),                                     -- Küçük resim URL (lobby icon)
    background_url VARCHAR(500),                                    -- Arka plan resim URL
    logo_url VARCHAR(500),                                          -- Oyun logo URL
    banner_url VARCHAR(500),                                        -- Promosyon banner URL

    -- Bahis Limitleri (Provider varsayılanları)
    min_bet DECIMAL(18,8),                                          -- Minimum bahis (provider default)
    max_bet DECIMAL(18,8),                                          -- Maksimum bahis (provider default)
    default_bet DECIMAL(18,8),                                      -- Varsayılan bahis

    -- Özellikler
    features VARCHAR(50)[] DEFAULT '{}',                            -- Özellikler: FREESPINS, MULTIPLIER, BONUS_BUY, GAMBLE, JACKPOT, MEGAWAYS, CLUSTER
    has_demo BOOLEAN NOT NULL DEFAULT true,                         -- Demo modu var mı
    has_jackpot BOOLEAN NOT NULL DEFAULT false,                     -- Jackpot oyunu mu
    jackpot_type VARCHAR(50),                                       -- Jackpot tipi: LOCAL, NETWORK, PROGRESSIVE, DAILY
    has_bonus_buy BOOLEAN NOT NULL DEFAULT false,                   -- Bonus satın alma özelliği

    -- Platform Desteği
    is_mobile BOOLEAN NOT NULL DEFAULT true,                        -- Mobil uyumlu mu
    is_desktop BOOLEAN NOT NULL DEFAULT true,                       -- Desktop uyumlu mu
    is_tablet BOOLEAN NOT NULL DEFAULT true,                        -- Tablet uyumlu mu
    supported_platforms VARCHAR(20)[] DEFAULT '{web,mobile,app}',   -- Desteklenen platformlar

    -- Desteklenen Ayarlar (Provider seviyesinde)
    supported_currencies CHAR(3)[] DEFAULT '{}',                    -- Desteklenen para birimleri
    supported_languages CHAR(2)[] DEFAULT '{}',                     -- Desteklenen diller
    blocked_countries CHAR(2)[] DEFAULT '{}',                       -- Engelli ülkeler

    -- Lisanslama / Compliance
    certified_jurisdictions VARCHAR(20)[] DEFAULT '{}',             -- Sertifikalı bölgeler: MGA, CURACAO, UKGC, ROMANIA
    age_restriction SMALLINT DEFAULT 18,                            -- Yaş sınırı

    -- Sıralama ve Popülerlik
    sort_order INTEGER DEFAULT 0,                                   -- Manuel sıralama
    popularity_score INTEGER DEFAULT 0,                             -- Popülerlik puanı (hesaplanır)

    -- Tarihler
    release_date DATE,                                              -- Oyun yayın tarihi
    provider_updated_at TIMESTAMP,                                  -- Provider'dan son güncelleme
    is_active BOOLEAN NOT NULL DEFAULT true,                        -- Aktif/pasif durumu
    created_at TIMESTAMP NOT NULL DEFAULT now(),                    -- Kayıt oluşturma zamanı
    updated_at TIMESTAMP NOT NULL DEFAULT now()                     -- Son güncelleme zamanı
);

COMMENT ON TABLE catalog.games IS 'Master game catalog synchronized from integrated game providers. Contains all game metadata, features, and configuration.';
