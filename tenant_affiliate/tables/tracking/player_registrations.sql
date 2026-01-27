-- =============================================
-- Tablo: tracking.player_registrations
-- Açıklama: Oyuncu kayıt attribution tablosu
-- Register sırasında affiliate ataması burada yapılır
-- Click → Register → FTD akışını takip eder
-- =============================================

DROP TABLE IF EXISTS tracking.player_registrations CASCADE;

CREATE TABLE tracking.player_registrations (
    id bigserial PRIMARY KEY,                              -- Benzersiz kayıt kimliği
    player_id bigint NOT NULL,                             -- Oyuncu ID (tenant.players)

    -- Attribution Kaynağı
    attribution_source varchar(30) NOT NULL,               -- AFFILIATE_LINK, REFERRAL, ORGANIC, PROMO_CODE, DIRECT

    -- Affiliate Bilgileri (attribution_source = AFFILIATE_LINK ise)
    affiliate_id bigint,                                   -- Affiliate ID
    campaign_id bigint,                                    -- Kampanya ID
    tracking_link_id bigint,                               -- Tracking link ID
    click_id uuid,                                         -- İlişkili click ID

    -- Referral Bilgileri (attribution_source = REFERRAL ise)
    referrer_player_id bigint,                             -- Referans veren oyuncu ID
    referral_code varchar(50),                             -- Referans kodu

    -- Promo Code (attribution_source = PROMO_CODE ise)
    promo_code varchar(50),                                -- Kullanılan promo kodu
    promo_affiliate_id bigint,                             -- Promo kodunun bağlı olduğu affiliate

    -- Kayıt Detayları
    registered_at timestamp without time zone NOT NULL DEFAULT now(),
    registration_ip inet,                                  -- Kayıt IP adresi
    registration_device varchar(20),                       -- DESKTOP, MOBILE, TABLET
    registration_country char(2),                          -- Kayıt ülkesi

    -- Sub-ID'ler (Click'ten taşınan)
    sub_id_1 varchar(100),
    sub_id_2 varchar(100),
    sub_id_3 varchar(100),
    sub_id_4 varchar(100),
    sub_id_5 varchar(100),

    -- Attribution Window
    click_to_register_seconds int,                         -- Tıklamadan kayda geçen süre
    is_within_attribution_window boolean DEFAULT true,     -- Attribution window içinde mi?

    -- FTD Bilgileri (sonradan güncellenir)
    is_ftd_completed boolean NOT NULL DEFAULT false,       -- FTD yaptı mı?
    ftd_at timestamp without time zone,                    -- FTD zamanı
    ftd_amount numeric(18,2),                              -- FTD tutarı
    ftd_currency char(3),                                  -- FTD para birimi
    click_to_ftd_seconds int,                              -- Tıklamadan FTD'ye geçen süre
    register_to_ftd_seconds int,                           -- Kayıttan FTD'ye geçen süre

    -- Kalifikasyon (CPA için)
    is_qualified boolean NOT NULL DEFAULT false,           -- Qualifying deposit yaptı mı?
    qualified_at timestamp without time zone,              -- Kalifikasyon zamanı
    qualification_reason varchar(100),                     -- Kalifikasyon sebebi

    -- Fraud Kontrolü
    is_fraud_suspected boolean NOT NULL DEFAULT false,     -- Fraud şüphesi var mı?
    fraud_flags jsonb,                                     -- Fraud flag'leri
    fraud_checked_at timestamp without time zone,          -- Son kontrol zamanı

    -- Meta
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone,

    CONSTRAINT uq_player_registration UNIQUE (player_id)
);

COMMENT ON TABLE tracking.player_registrations IS 'Player registration attribution - links new players to affiliate/referral source for commission tracking';
COMMENT ON COLUMN tracking.player_registrations.is_qualified IS 'True if player made qualifying deposit for CPA commission';

-- =============================================
-- Register Akışı:
--
-- 1. Ziyaretçi kayıt formunu doldurur
--
-- 2. Backend cookie'yi kontrol eder:
--    - aff_click_id varsa → AFFILIATE_LINK
--    - referral_code varsa → REFERRAL
--    - promo_code varsa → PROMO_CODE
--    - Hiçbiri yoksa → ORGANIC veya DIRECT
--
-- 3. player_registrations kaydı oluşur:
--    - attribution_source belirlenir
--    - affiliate_id, campaign_id atanır
--    - click_id ilişkilendirilir
--
-- 4. player_affiliate_current güncellenir:
--    - affiliate_id = kayıttaki affiliate
--    - campaign_id = kayıttaki kampanya
--
-- 5. player_affiliate_history'e ASSIGNED kaydı eklenir
--
-- 6. link_clicks tablosunda is_converted = true yapılır
--
-- 7. tracking_links istatistikleri güncellenir:
--    - total_registrations += 1
-- =============================================
