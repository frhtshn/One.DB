-- =============================================
-- Promotion Segments (Hedef Kitle Segmentleri)
-- Promosyonun hangi oyuncu gruplarına gösterileceği
-- Dahil etme (include) veya hariç tutma (exclude) mantığı
-- =============================================

DROP TABLE IF EXISTS content.promotion_segments CASCADE;

CREATE TABLE content.promotion_segments (
    id SERIAL PRIMARY KEY,
    promotion_id INTEGER NOT NULL,                -- Bağlı promosyon
    segment_type VARCHAR(30) NOT NULL,            -- Segment tipi (aşağıya bak)
    segment_value VARCHAR(100),                   -- Segment değeri
    is_include BOOLEAN NOT NULL DEFAULT TRUE,     -- TRUE: dahil et, FALSE: hariç tut
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER
);

COMMENT ON TABLE content.promotion_segments IS 'Promotion audience targeting by player category, VIP level, country, or custom segments';

-- Segment tipleri:
-- player_category: Oyuncu kategorisi (bronze, silver, gold, platinum)
-- player_group: Oyuncu grubu ID'si
-- vip_level: VIP seviyesi (1, 2, 3...)
-- country: Ülke kodu (TR, DE, GB)
-- currency: Para birimi (TRY, EUR, USD)
-- registration_date: Kayıt tarihi aralığı (2024-01-01:2024-12-31)
-- deposit_count: Depozit sayısı aralığı (0:5 = 0-5 arası depozit yapanlar)
-- custom: Özel segment tanımı
