-- =============================================
-- Promotions (Promosyonlar)
-- Site promosyonlarının ana tablosu
-- Bonus modülüyle entegre çalışır
-- =============================================

DROP TABLE IF EXISTS content.promotions CASCADE;

CREATE TABLE content.promotions (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL,                    -- Benzersiz promosyon kodu (welcome_bonus, friday_reload)
    promotion_type_id INTEGER NOT NULL,           -- Promosyon türü (promotion_types tablosuna referans)
    bonus_id INTEGER,                             -- Bağlı bonus kuralı (bonus.bonus_rules tablosuna referans)
    min_deposit NUMERIC(18,2),                    -- Minimum depozit tutarı (varsa)
    max_deposit NUMERIC(18,2),                    -- Maksimum depozit tutarı (varsa)
    start_date TIMESTAMP WITHOUT TIME ZONE,       -- Promosyon başlangıç tarihi
    end_date TIMESTAMP WITHOUT TIME ZONE,         -- Promosyon bitiş tarihi
    sort_order INTEGER NOT NULL DEFAULT 0,        -- Gösterim sırası
    is_featured BOOLEAN NOT NULL DEFAULT FALSE,   -- Öne çıkan promosyon mu?
    is_new_members_only BOOLEAN NOT NULL DEFAULT FALSE, -- Sadece yeni üyelere mi?
    is_active BOOLEAN NOT NULL DEFAULT TRUE,      -- Aktif mi?
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    updated_by INTEGER
);

COMMENT ON TABLE content.promotions IS 'Site promotions master table integrated with bonus module for welcome, deposit, and seasonal offers';
