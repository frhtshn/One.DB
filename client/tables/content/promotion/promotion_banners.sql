-- =============================================
-- Promotion Banners (Promosyon Görselleri)
-- Her promosyon için cihaz ve dil bazlı bannerlar
-- Desktop, mobil, tablet için farklı boyutlar
-- =============================================

DROP TABLE IF EXISTS content.promotion_banners CASCADE;

CREATE TABLE content.promotion_banners (
    id SERIAL PRIMARY KEY,
    promotion_id INTEGER NOT NULL,                -- Bağlı promosyon
    language_code CHAR(2),                        -- Dil kodu (NULL = tüm diller için geçerli)
    device_type VARCHAR(20) NOT NULL DEFAULT 'desktop', -- Cihaz tipi: desktop, mobile, tablet, app
    image_url VARCHAR(500) NOT NULL,              -- Görsel URL'i (CDN adresi)
    alt_text VARCHAR(255),                        -- Erişilebilirlik için alternatif metin
    width INTEGER,                                -- Görsel genişliği (px)
    height INTEGER,                               -- Görsel yüksekliği (px)
    sort_order INTEGER NOT NULL DEFAULT 0,        -- Birden fazla banner varsa sıralama
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER
);

COMMENT ON TABLE content.promotion_banners IS 'Promotion banner images per device type and language for responsive display';
