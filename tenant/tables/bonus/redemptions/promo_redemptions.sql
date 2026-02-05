-- =============================================
-- Promo Redemptions (Promosyon Kod Kullanımları)
-- Oyuncuların kullandığı promosyon kodları
-- Tekrar kullanımı önlemek için kayıt tutulur
-- =============================================

DROP TABLE IF EXISTS bonus.promo_redemptions CASCADE;

CREATE TABLE bonus.promo_redemptions (
    id bigserial PRIMARY KEY,

    -- Oyuncu bilgisi
    player_id bigint NOT NULL,                    -- Oyuncu ID

    -- Promosyon bilgileri
    promo_code_id bigint NOT NULL,                -- Promosyon kodu ID
    promo_code varchar(50) NOT NULL,              -- Kullanılan kod: WELCOME100, FRIDAY50
    bonus_award_id bigint,                        -- Oluşturulan bonus ID

    -- Durum
    status varchar(20) NOT NULL DEFAULT 'success', -- Durum: success, failed, expired
    failure_reason varchar(255),                  -- Başarısızlık sebebi

    redeemed_at timestamp without time zone NOT NULL DEFAULT now(), -- Kullanım tarihi
    created_at timestamp without time zone NOT NULL DEFAULT now()
);

COMMENT ON TABLE bonus.promo_redemptions IS 'Promotional code redemption records tracking player usage to prevent duplicate redemptions';
