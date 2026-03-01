-- =============================================
-- Slide Images (Slide Görselleri)
-- Cihaz ve dil bazlı responsive görseller
-- Desktop, mobil, tablet için farklı boyutlar
-- =============================================

DROP TABLE IF EXISTS content.slide_images CASCADE;

CREATE TABLE content.slide_images (
    id SERIAL PRIMARY KEY,
    slide_id INTEGER NOT NULL,                    -- Bağlı slide
    language_code CHAR(2),                        -- Dil kodu (NULL = tüm diller için)
    device_type VARCHAR(20) NOT NULL DEFAULT 'desktop', -- Cihaz: desktop, mobile, tablet

    -- Görsel Bilgileri
    image_url VARCHAR(500) NOT NULL,              -- Görsel URL'i (CDN adresi)
    image_url_2x VARCHAR(500),                    -- Retina görsel (2x)
    image_url_webp VARCHAR(500),                  -- WebP formatı (optimizasyon)

    -- Boyutlar
    width INTEGER,                                -- Görsel genişliği (px)
    height INTEGER,                               -- Görsel yüksekliği (px)
    file_size INTEGER,                            -- Dosya boyutu (bytes)

    -- Alternatif
    fallback_color VARCHAR(7),                    -- Görsel yüklenemezse arka plan rengi (#HEX)

    -- Sıralama (aynı cihaz için birden fazla görsel varsa)
    sort_order INTEGER NOT NULL DEFAULT 0,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    updated_by INTEGER
);

COMMENT ON TABLE content.slide_images IS 'Responsive slide images per device type and language with retina and WebP support';

-- Device type değerleri:
-- desktop: Masaüstü (>1024px)
-- tablet: Tablet (768-1024px)
-- mobile: Mobil (<768px)
-- app: Mobil uygulama
