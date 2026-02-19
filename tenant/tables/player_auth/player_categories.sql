-- =============================================
-- Player Categories (Oyuncu Kategorileri)
-- Oyuncu segmentasyonu için kategoriler
-- Örnek: Bronze, Silver, Gold, Platinum, VIP
-- =============================================

DROP TABLE IF EXISTS auth.player_categories CASCADE;

CREATE TABLE auth.player_categories (
    id bigserial PRIMARY KEY,
    category_code varchar(50) NOT NULL,           -- Kategori kodu: bronze, silver, gold
    category_name varchar(100) NOT NULL,          -- Kategori adı: "Altın Üye"
    description varchar(255),                     -- Açıklama
    level int NOT NULL DEFAULT 0,                 -- Hiyerarşi seviyesi (yüksek = daha iyi)
    is_active boolean NOT NULL DEFAULT true,      -- Soft delete desteği
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE auth.player_categories IS 'Player segmentation categories for VIP tiers such as Bronze, Silver, Gold, Platinum';
