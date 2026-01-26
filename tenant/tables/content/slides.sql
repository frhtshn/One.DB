-- =============================================
-- Slides (Ana Slide Tablosu)
-- Tüm slide içeriklerinin ana kaydı
-- Zamanlama, hedefleme ve görüntüleme ayarları
-- =============================================

DROP TABLE IF EXISTS content.slides CASCADE;

CREATE TABLE content.slides (
    id SERIAL PRIMARY KEY,
    placement_id INTEGER NOT NULL,                -- Gösterim alanı (slide_placements)
    category_id INTEGER,                          -- Kategori (slide_categories) - opsiyonel
    code VARCHAR(50),                             -- Benzersiz slide kodu (API referansı için)

    -- Sıralama ve Öncelik
    sort_order INTEGER NOT NULL DEFAULT 0,        -- Gösterim sırası
    priority INTEGER NOT NULL DEFAULT 0,          -- Öncelik (yüksek = daha önemli)

    -- Link Ayarları
    link_url VARCHAR(500),                        -- Tıklama hedef URL'i
    link_target VARCHAR(20) DEFAULT '_self',      -- Link açılış: _self, _blank, _modal
    link_type VARCHAR(20) DEFAULT 'url',          -- Link tipi: url, game, promotion, page
    link_reference VARCHAR(100),                  -- Referans ID (game_id, promotion_id, page_slug)

    -- Tarih Aralığı
    start_date TIMESTAMP WITHOUT TIME ZONE,       -- Gösterim başlangıç tarihi (NULL = hemen)
    end_date TIMESTAMP WITHOUT TIME ZONE,         -- Gösterim bitiş tarihi (NULL = süresiz)

    -- Hedefleme
    segment_ids INTEGER[],                        -- Hedef segment ID'leri (NULL = herkes)
    country_codes CHAR(2)[],                      -- Hedef ülkeler (NULL = tümü)
    excluded_country_codes CHAR(2)[],             -- Hariç tutulan ülkeler

    -- Görüntüleme Ayarları
    display_duration INTEGER,                     -- Otomatik geçiş süresi (saniye)
    animation_type VARCHAR(30) DEFAULT 'fade',    -- Animasyon: fade, slide, zoom, none

    -- Durum
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,

    -- Audit
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    updated_by INTEGER,
    deleted_at TIMESTAMP WITHOUT TIME ZONE,
    deleted_by INTEGER
);

COMMENT ON TABLE content.slides IS 'Main slide/banner content with scheduling, targeting, and display configuration';

-- Link type örnekleri:
-- url: Dış veya iç link (link_url kullanılır)
-- game: Oyun detay sayfası (link_reference = game_code)
-- promotion: Promosyon detay (link_reference = promotion_id)
-- page: CMS sayfası (link_reference = page_slug)
-- deposit: Para yatırma sayfası
-- register: Kayıt sayfası
