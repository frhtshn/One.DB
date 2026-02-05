-- =============================================
-- Promotion Types (Promosyon Türleri)
-- Promosyon kategorileri ve davranış tanımları
-- =============================================

DROP TABLE IF EXISTS content.promotion_types CASCADE;

CREATE TABLE content.promotion_types (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL,                    -- Benzersiz tür kodu
    icon VARCHAR(50),                             -- Tür ikonu (gift, percent, star, etc.)
    color VARCHAR(20),                            -- Tema rengi (#FF5733, red, etc.)
    badge_text VARCHAR(30),                       -- Rozet metni (NEW, HOT, VIP, etc.)
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    updated_by INTEGER
);

COMMENT ON TABLE content.promotion_types IS 'Promotion type definitions for categorizing promotions';

-- Örnek promosyon türleri:
-- welcome: Hoşgeldin bonusu
-- deposit: Yatırım bonusu
-- cashback: Kayıp iadesi
-- freespin: Bedava dönüş
-- tournament: Turnuva
-- vip: VIP özel
-- seasonal: Sezonluk kampanya
-- reload: Yeniden yükleme bonusu
