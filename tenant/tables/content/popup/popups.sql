-- =============================================
-- Popups (Ana Popup Tablosu)
-- Tüm popup içeriklerinin ana kaydı
-- Zamanlama, görüntüleme ve hedefleme ayarları
-- =============================================

DROP TABLE IF EXISTS content.popups CASCADE;

CREATE TABLE content.popups (
    id SERIAL PRIMARY KEY,
    popup_type_id INTEGER NOT NULL,               -- Popup türü (modal, fullscreen, vb.)
    code VARCHAR(50),                             -- Benzersiz popup kodu (API referansı)

    -- Görüntüleme Süresi
    display_duration INTEGER,                     -- Ekranda kalma süresi (saniye, NULL = manuel kapatma)
    auto_close BOOLEAN NOT NULL DEFAULT FALSE,    -- Süre dolunca otomatik kapansın mı

    -- Boyutlar (NULL ise popup_type'dan alınır)
    width INTEGER,                                -- Genişlik (px)
    height INTEGER,                               -- Yükseklik (px)

    -- Tetikleyici
    trigger_type VARCHAR(30) NOT NULL DEFAULT 'immediate', -- Tetikleme türü
    trigger_delay INTEGER DEFAULT 0,              -- Tetikleme gecikmesi (saniye)
    trigger_scroll_percent INTEGER,               -- Scroll yüzdesi (trigger_type='scroll' için)
    trigger_exit_intent BOOLEAN DEFAULT FALSE,    -- Çıkış niyetinde göster

    -- Sıklık Kontrolü
    frequency_type VARCHAR(30) DEFAULT 'once_per_session', -- Gösterim sıklığı
    frequency_cap INTEGER,                        -- Maksimum gösterim sayısı
    frequency_hours INTEGER,                      -- Kaç saat sonra tekrar gösterilsin

    -- Link Ayarları
    link_url VARCHAR(500),                        -- Tıklama hedef URL'i
    link_target VARCHAR(20) DEFAULT '_self',      -- Link açılış: _self, _blank

    -- Tarih Aralığı
    start_date TIMESTAMP WITHOUT TIME ZONE,       -- Gösterim başlangıç tarihi
    end_date TIMESTAMP WITHOUT TIME ZONE,         -- Gösterim bitiş tarihi

    -- Hedefleme
    segment_ids INTEGER[],                        -- Hedef segment ID'leri
    country_codes CHAR(2)[],                      -- Hedef ülkeler
    excluded_country_codes CHAR(2)[],             -- Hariç tutulan ülkeler

    -- Sayfa Hedefleme
    page_urls TEXT[],                             -- Gösterilecek sayfa URL'leri (NULL = tümü)
    excluded_page_urls TEXT[],                    -- Hariç tutulan sayfalar

    -- Öncelik
    priority INTEGER NOT NULL DEFAULT 0,          -- Öncelik (yüksek = daha önemli)

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

COMMENT ON TABLE content.popups IS 'Main popup content with display duration, scheduling, triggers, and targeting';

-- trigger_type değerleri:
-- immediate: Sayfa yüklenince hemen
-- delay: Belirli süre sonra (trigger_delay)
-- scroll: Belirli scroll yüzdesinde (trigger_scroll_percent)
-- exit_intent: Çıkış niyetinde (mouse sayfa dışına)
-- click: Belirli elemente tıklayınca
-- login: Giriş sonrası
-- first_visit: İlk ziyarette
-- returning_visit: Tekrar ziyarette

-- frequency_type değerleri:
-- always: Her seferinde göster
-- once_per_session: Oturum başına bir kez
-- once_per_day: Günde bir kez
-- once_per_week: Haftada bir kez
-- once_ever: Sadece bir kez (cookie/localStorage)
-- custom: Özel sıklık (frequency_hours kullanılır)
