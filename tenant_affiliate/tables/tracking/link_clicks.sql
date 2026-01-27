-- =============================================
-- Tablo: tracking.link_clicks
-- Açıklama: Link tıklama kayıtları
-- Her tıklama için detaylı log
-- Cookie set etme ve attribution için kullanılır
-- =============================================

DROP TABLE IF EXISTS tracking.link_clicks CASCADE;

CREATE TABLE tracking.link_clicks (
    id bigserial PRIMARY KEY,                              -- Benzersiz tıklama kimliği
    tracking_link_id bigint NOT NULL,                      -- Link ID (FK: tracking.tracking_links)
    affiliate_id bigint NOT NULL,                          -- Affiliate ID (denormalize)
    campaign_id bigint,                                    -- Kampanya ID (denormalize)

    -- Tıklama Bilgileri
    click_id uuid NOT NULL DEFAULT gen_random_uuid(),      -- Benzersiz click ID (cookie'de saklanır)
    clicked_at timestamp without time zone NOT NULL DEFAULT now(), -- Tıklama zamanı

    -- Ziyaretçi Bilgileri
    visitor_id varchar(64),                                -- Fingerprint/visitor ID
    ip_address inet NOT NULL,                              -- IP adresi
    user_agent varchar(500),                               -- Tarayıcı bilgisi

    -- Cihaz Bilgileri
    device_type varchar(20),                               -- DESKTOP, MOBILE, TABLET
    os varchar(50),                                        -- Windows, iOS, Android, etc.
    browser varchar(50),                                   -- Chrome, Safari, Firefox, etc.

    -- Konum Bilgileri (GeoIP)
    country_code char(2),                                  -- Ülke kodu
    region varchar(100),                                   -- Bölge/Eyalet
    city varchar(100),                                     -- Şehir

    -- Referrer Bilgileri
    referrer_url varchar(500),                             -- Nereden geldi
    referrer_domain varchar(255),                          -- Referrer domain

    -- Landing Page
    landing_url varchar(500),                              -- Gelinen URL
    landing_page varchar(100),                             -- Landing page kodu

    -- Sub-ID'ler (Affiliate'in kendi takibi)
    sub_id_1 varchar(100),                                 -- Sub ID 1
    sub_id_2 varchar(100),                                 -- Sub ID 2
    sub_id_3 varchar(100),                                 -- Sub ID 3
    sub_id_4 varchar(100),                                 -- Sub ID 4
    sub_id_5 varchar(100),                                 -- Sub ID 5

    -- UTM Parametreleri
    utm_source varchar(100),
    utm_medium varchar(100),
    utm_campaign varchar(100),
    utm_content varchar(100),
    utm_term varchar(100),

    -- Dönüşüm Durumu
    is_converted boolean NOT NULL DEFAULT false,           -- Kayıt oldu mu?
    converted_player_id bigint,                            -- Dönüşen oyuncu ID
    converted_at timestamp without time zone,              -- Dönüşüm zamanı

    -- Benzersizlik
    is_unique boolean NOT NULL DEFAULT true,               -- İlk tıklama mı? (24 saat içinde)

    -- Meta
    raw_query_params jsonb,                                -- Tüm URL parametreleri
    created_at timestamp without time zone NOT NULL DEFAULT now()
);

COMMENT ON TABLE tracking.link_clicks IS 'Click tracking log for affiliate links - captures visitor data for attribution';
COMMENT ON COLUMN tracking.link_clicks.click_id IS 'Unique click identifier stored in visitor cookie for attribution';
COMMENT ON COLUMN tracking.link_clicks.is_unique IS 'First click from this visitor in 24 hours';

-- =============================================
-- Örnek Click Akışı:
--
-- 1. Ziyaretçi affiliate linkine tıklar
--    GET https://casino.com/?ref=AFF123&sub1=youtube
--
-- 2. link_clicks kaydı oluşur:
--    - click_id: uuid oluşturulur
--    - affiliate_id: AFF123'ün affiliate ID'si
--    - ip_address, user_agent, device bilgileri kaydedilir
--    - sub_id_1: 'youtube'
--
-- 3. Cookie set edilir:
--    - aff_click_id = click_id
--    - aff_ref = AFF123
--    - Süre: 30 gün (link ayarına göre)
--
-- 4. Ziyaretçi kayıt olursa:
--    - is_converted = true
--    - converted_player_id = yeni oyuncu ID
--    - converted_at = kayıt zamanı
-- =============================================
