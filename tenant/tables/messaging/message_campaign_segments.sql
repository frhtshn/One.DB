-- =============================================
-- Tablo: messaging.message_campaign_segments
-- Kampanya hedef kitle segmentasyonu
-- Dahil etme (include) veya hariç tutma (exclude) mantığı
-- promotion_segments tablosu ile aynı desen
-- =============================================

DROP TABLE IF EXISTS messaging.message_campaign_segments CASCADE;

CREATE TABLE messaging.message_campaign_segments (
    id SERIAL PRIMARY KEY,
    campaign_id INTEGER NOT NULL,                 -- Bağlı kampanya
    segment_type VARCHAR(30) NOT NULL,            -- Segment tipi (aşağıya bak)
    segment_value VARCHAR(255),                   -- Segment değeri
    is_include BOOLEAN NOT NULL DEFAULT TRUE,     -- TRUE: dahil et, FALSE: hariç tut
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER
);

COMMENT ON TABLE messaging.message_campaign_segments IS 'Campaign audience targeting by player category, group, country, gender, status, and custom segments';

-- Segment tipleri:
-- player_category: Oyuncu kategorisi (bronze, silver, gold, platinum)
-- player_group: Oyuncu grubu ID'si (high_rollers, new_members)
-- country: Ülke kodu (TR, DE, GB)
-- gender: Cinsiyet (0, 1, 2)
-- player_status: Oyuncu durumu (0, 1, 2, 3)
-- registration_date: Kayıt tarihi aralığı (2024-01-01:2024-12-31)
-- last_login_date: Son giriş tarihi aralığı
-- deposit_count: Depozit sayısı aralığı (0:5)
-- custom: Özel segment tanımı
