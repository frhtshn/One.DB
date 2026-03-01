-- =============================================
-- Tablo: tracking.tracking_links
-- Açıklama: Affiliate takip linkleri
-- Her affiliate'in benzersiz referans linkleri
-- Direkt link veya kampanya bazlı link olabilir
-- =============================================

DROP TABLE IF EXISTS tracking.tracking_links CASCADE;

CREATE TABLE tracking.tracking_links (
    id bigserial PRIMARY KEY,                              -- Benzersiz link kimliği
    affiliate_id bigint NOT NULL,                          -- Affiliate ID (FK: affiliate.affiliates)
    campaign_id bigint,                                    -- Kampanya ID (NULL = direkt link)

    -- Link Tanımlayıcıları
    tracking_code varchar(50) NOT NULL,                    -- Benzersiz takip kodu (URL'de kullanılır)
    short_code varchar(20),                                -- Kısa kod (opsiyonel, örn: abc123)
    custom_slug varchar(100),                              -- Özel slug (örn: /bonus-casino)

    -- Link Tipi
    link_type varchar(20) NOT NULL DEFAULT 'STANDARD',     -- STANDARD, CAMPAIGN, DEEPLINK, POSTBACK

    -- Hedef Ayarları
    destination_url varchar(500),                          -- Özel hedef URL (NULL = varsayılan)
    landing_page varchar(100),                             -- Landing page kodu
    default_params jsonb,                                  -- Varsayılan URL parametreleri

    -- Sub-ID Desteği (Affiliate'in kendi takibi için)
    allow_sub_ids boolean NOT NULL DEFAULT true,           -- Sub-ID parametrelerine izin ver
    sub_id_params jsonb,                                   -- İzin verilen sub-id param isimleri

    -- Attribution Ayarları
    attribution_model_id bigint,                           -- Attribution modeli (FK)
    cookie_duration_days smallint DEFAULT 30,              -- Cookie süresi (gün)

    -- Durum
    is_active boolean NOT NULL DEFAULT true,               -- Link aktif mi?
    expires_at timestamp without time zone,                -- Son kullanma tarihi

    -- İstatistik (Denormalize - hızlı erişim için)
    total_clicks bigint NOT NULL DEFAULT 0,                -- Toplam tıklama
    unique_clicks bigint NOT NULL DEFAULT 0,               -- Benzersiz tıklama
    total_registrations int NOT NULL DEFAULT 0,            -- Toplam kayıt
    total_ftd int NOT NULL DEFAULT 0,                      -- Toplam FTD

    -- Meta
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone,
    created_by_user_id bigint,                             -- Oluşturan kullanıcı

    CONSTRAINT uq_tracking_code UNIQUE (tracking_code),
    CONSTRAINT uq_short_code UNIQUE (short_code)
);

COMMENT ON TABLE tracking.tracking_links IS 'Affiliate tracking links for player acquisition - supports direct links, campaign links, and deep links';
COMMENT ON COLUMN tracking.tracking_links.tracking_code IS 'Unique tracking code used in URL, e.g., ?ref=ABC123XYZ';
COMMENT ON COLUMN tracking.tracking_links.short_code IS 'Optional short code for friendly URLs, e.g., /r/abc123';

-- =============================================
-- Link Format Örnekleri:
--
-- 1. STANDART LİNK (Direkt Affiliate):
--    https://casino.com/?ref=AFF123ABC
--    → tracking_code: AFF123ABC
--    → campaign_id: NULL
--
-- 2. KAMPANYA LİNKİ:
--    https://casino.com/?ref=AFF123ABC&camp=SUMMER2026
--    → tracking_code: AFF123ABC_SUMMER2026
--    → campaign_id: 15
--
-- 3. KISA LİNK:
--    https://casino.com/r/xyz789
--    → short_code: xyz789
--
-- 4. DEEP LINK:
--    https://casino.com/slots/sweet-bonanza?ref=AFF123ABC
--    → tracking_code: AFF123ABC
--    → landing_page: slots/sweet-bonanza
--
-- 5. SUB-ID'Lİ LİNK (Affiliate'in kendi takibi):
--    https://casino.com/?ref=AFF123ABC&sub1=youtube&sub2=video123
--    → sub_id_params: {"sub1": "youtube", "sub2": "video123"}
-- =============================================
