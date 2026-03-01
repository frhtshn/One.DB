-- =============================================
-- Tablo: tracking.promo_codes
-- Açıklama: Affiliate promo kodları
-- Link yerine kod ile attribution yapılabilir
-- Influencer, TV reklamı vb. için idealdir
-- =============================================

DROP TABLE IF EXISTS tracking.promo_codes CASCADE;

CREATE TABLE tracking.promo_codes (
    id bigserial PRIMARY KEY,                              -- Benzersiz kod kimliği
    code varchar(50) NOT NULL,                             -- Promo kodu (SUMMER2026, YOUTUBE50 vb.)
    code_type varchar(20) NOT NULL DEFAULT 'AFFILIATE',    -- AFFILIATE, CAMPAIGN, GENERAL

    -- Attribution
    affiliate_id bigint,                                   -- Bağlı affiliate ID
    campaign_id bigint,                                    -- Bağlı kampanya ID

    -- Bonus/Promosyon (opsiyonel)
    bonus_id bigint,                                       -- Bağlı bonus ID (client bonus tablosu)
    bonus_description varchar(255),                        -- Bonus açıklaması

    -- Kullanım Limitleri
    max_uses int,                                          -- Maksimum kullanım (NULL = sınırsız)
    max_uses_per_player int DEFAULT 1,                     -- Oyuncu başına max kullanım
    current_uses int NOT NULL DEFAULT 0,                   -- Mevcut kullanım sayısı

    -- Geçerlilik
    valid_from timestamp without time zone NOT NULL DEFAULT now(),
    valid_to timestamp without time zone,                  -- NULL = süresiz

    -- Hedefleme
    allowed_countries jsonb,                               -- İzin verilen ülkeler: ["TR", "DE", "GB"]
    excluded_countries jsonb,                              -- Yasaklı ülkeler
    min_deposit_amount numeric(18,2),                      -- Minimum depozit şartı

    -- Durum
    is_active boolean NOT NULL DEFAULT true,

    -- Meta
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone,
    created_by_user_id bigint,

    CONSTRAINT uq_promo_code UNIQUE (code)
);

COMMENT ON TABLE tracking.promo_codes IS 'Affiliate promo codes for attribution without tracking links - ideal for influencers, TV ads, print media';

-- =============================================
-- Örnek Promo Kodları:
--
-- 1. INFLUENCER KODU:
--    code: YOUTUBE50
--    affiliate_id: 123 (Influencer'ın affiliate ID'si)
--    bonus_description: "50 Freespin Hoşgeldin Bonusu"
--
-- 2. KAMPANYA KODU:
--    code: SUMMER2026
--    campaign_id: 45
--    valid_from: 2026-06-01
--    valid_to: 2026-08-31
--
-- 3. TV REKLAM KODU:
--    code: TV100
--    affiliate_id: 456 (Medya ajansı)
--    max_uses: 10000
-- =============================================
