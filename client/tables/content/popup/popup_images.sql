-- =============================================
-- Popup Images (Popup Görselleri)
-- Cihaz ve dil bazlı popup görselleri
-- =============================================

DROP TABLE IF EXISTS content.popup_images CASCADE;

CREATE TABLE content.popup_images (
    id SERIAL PRIMARY KEY,
    popup_id INTEGER NOT NULL,                    -- Bağlı popup
    language_code CHAR(2),                        -- Dil kodu (NULL = tüm diller)
    device_type VARCHAR(20) NOT NULL DEFAULT 'desktop', -- Cihaz: desktop, mobile, tablet
    image_position VARCHAR(20) DEFAULT 'top',     -- Görsel pozisyonu: top, left, right, background, full

    -- Görsel Bilgileri
    image_url VARCHAR(500) NOT NULL,              -- Görsel URL'i (CDN)
    image_url_2x VARCHAR(500),                    -- Retina görsel (2x)
    image_url_webp VARCHAR(500),                  -- WebP formatı

    -- Boyutlar
    width INTEGER,                                -- Görsel genişliği (px)
    height INTEGER,                               -- Görsel yüksekliği (px)
    file_size INTEGER,                            -- Dosya boyutu (bytes)

    -- Stil
    object_fit VARCHAR(20) DEFAULT 'cover',       -- CSS object-fit: cover, contain, fill
    border_radius INTEGER DEFAULT 0,              -- Köşe yuvarlaklığı (px)

    sort_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    updated_by INTEGER
);

COMMENT ON TABLE content.popup_images IS 'Popup images per device and language with positioning options';

-- image_position değerleri:
-- top: Başlığın üstünde
-- bottom: İçeriğin altında
-- left: Sol tarafta (içerik sağda)
-- right: Sağ tarafta (içerik solda)
-- background: Arkaplan görseli
-- full: Tam popup görseli (metin overlay)
