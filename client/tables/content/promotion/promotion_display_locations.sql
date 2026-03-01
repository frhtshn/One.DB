-- =============================================
-- Promotion Display Locations (Gösterim Alanları)
-- Promosyonların sitede nerede gösterileceği
-- Bir promosyon birden fazla alanda gösterilebilir
-- =============================================

DROP TABLE IF EXISTS content.promotion_display_locations CASCADE;

CREATE TABLE content.promotion_display_locations (
    id SERIAL PRIMARY KEY,
    promotion_id INTEGER NOT NULL,                -- Bağlı promosyon
    location_code VARCHAR(50) NOT NULL,           -- Gösterim alanı: homepage, lobby, deposit, profile, promotions_page, slider, popup, sidebar
    sort_order INTEGER NOT NULL DEFAULT 0,        -- O alandaki sıralama
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER
);

COMMENT ON TABLE content.promotion_display_locations IS 'Promotion placement configuration for homepage, lobby, deposit page, and other display areas';

-- Örnek kullanım:
-- homepage: Ana sayfa promosyon bloğu
-- lobby: Oyun lobisi banner alanı
-- deposit: Para yatırma sayfası önerileri
-- profile: Kullanıcı profili promosyonlar sekmesi
-- promotions_page: Promosyonlar sayfası listesi
-- slider: Ana sayfa slider/carousel
-- popup: Giriş sonrası popup
-- sidebar: Yan menü promosyon alanı
