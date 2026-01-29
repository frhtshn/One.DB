-- =============================================
-- Slide Categories (Slide Kategorileri)
-- Slide'ların türüne göre kategorilenmesi
-- Filtreleme ve raporlama için kullanılır
-- =============================================

DROP TABLE IF EXISTS content.slide_categories CASCADE;

CREATE TABLE content.slide_categories (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL,                    -- Benzersiz kategori kodu
    icon VARCHAR(50),                             -- Kategori ikonu (icon class veya emoji)
    color VARCHAR(20),                            -- Kategori rengi (hex code)
    sort_order INTEGER NOT NULL DEFAULT 0,        -- Sıralama
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    updated_by INTEGER
);

COMMENT ON TABLE content.slide_categories IS 'Slide category definitions for organization and filtering';

-- Örnek kategori kodları:
-- welcome: Hoşgeldin slide'ları
-- promotion: Promosyon duyuruları
-- event: Özel etkinlikler (turnuva, maç)
-- announcement: Genel duyurular
-- game_highlight: Öne çıkan oyunlar
-- new_game: Yeni oyun tanıtımları
-- seasonal: Mevsimsel kampanyalar (Noel, Yılbaşı)
-- vip: VIP özel içerikler
-- sports: Spor bahisleri özel
-- casino: Casino özel
