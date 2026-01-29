-- =============================================
-- Slide Placements (Gösterim Alanları)
-- Slide'ların sitede nerede gösterileceği
-- Her alan için max slide sayısı belirlenebilir
-- =============================================

DROP TABLE IF EXISTS content.slide_placements CASCADE;

CREATE TABLE content.slide_placements (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL,                    -- Benzersiz alan kodu: home_hero, casino_top, sports_banner
    name VARCHAR(100) NOT NULL,                   -- Alan adı
    description VARCHAR(500),                     -- Açıklama
    max_slides INTEGER NOT NULL DEFAULT 5,        -- Bu alanda gösterilebilecek max slide sayısı
    width INTEGER,                                -- Önerilen görsel genişliği (px)
    height INTEGER,                               -- Önerilen görsel yüksekliği (px)
    aspect_ratio VARCHAR(10),                     -- Önerilen en-boy oranı: 16:9, 4:3, 1:1
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    updated_by INTEGER
);

COMMENT ON TABLE content.slide_placements IS 'Slide display areas/positions on the website with recommended dimensions';

-- Örnek placement kodları:
-- home_hero: Ana sayfa büyük slider
-- home_secondary: Ana sayfa ikincil banner alanı
-- casino_top: Casino sayfası üst banner
-- casino_sidebar: Casino yan menü
-- sports_hero: Spor bahisleri ana slider
-- sports_event: Spor etkinlik banner
-- promo_page: Promosyonlar sayfası slider
-- deposit_banner: Para yatırma sayfası banner
-- lobby_top: Oyun lobisi üst alan
-- popup_welcome: Karşılama popup
-- popup_promo: Promosyon popup
