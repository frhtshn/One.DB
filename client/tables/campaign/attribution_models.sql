-- =============================================
-- Tablo: campaign.attribution_models
-- Açıklama: Attribution (atıf) model tanımları
-- Kampanyaların hangi modele göre takip edileceğini belirler
-- Örnek: FIRST_CLICK, LAST_CLICK, LINEAR, TIME_DECAY
-- =============================================

DROP TABLE IF EXISTS campaign.attribution_models CASCADE;

CREATE TABLE campaign.attribution_models (
    id smallint PRIMARY KEY,                               -- Benzersiz model kimliği
    code varchar(30) UNIQUE NOT NULL,                      -- Model kodu: FIRST_CLICK, LAST_CLICK, LINEAR
    name varchar(100) NOT NULL,                            -- Model adı
    description varchar(255),                              -- Model açıklaması

    -- Attribution Window
    default_window_days smallint NOT NULL DEFAULT 30,      -- Varsayılan attribution penceresi (gün)
    max_window_days smallint NOT NULL DEFAULT 90,          -- Maksimum attribution penceresi

    -- Çoklu Tıklama Davranışı
    multi_touch_behavior varchar(30) NOT NULL DEFAULT 'FIRST', -- FIRST, LAST, ALL

    -- Ayarlar
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp without time zone NOT NULL DEFAULT now()
);

COMMENT ON TABLE campaign.attribution_models IS 'Attribution model definitions for campaign tracking - determines which click gets credit for conversion';

-- =============================================
-- Attribution Modelleri:
--
-- 1. FIRST_CLICK (Varsayılan):
--    - İlk tıklayan affiliate tüm kredyi alır
--    - Marka bilinirliği için ideal
--    - multi_touch_behavior: FIRST
--
-- 2. LAST_CLICK:
--    - Son tıklayan affiliate tüm kredyi alır
--    - Dönüşüm odaklı
--    - multi_touch_behavior: LAST
--
-- 3. LAST_NON_DIRECT:
--    - Son affiliate tıklaması (direct hariç)
--    - Direkt ziyaretler sayılmaz
--
-- 4. LINEAR (Çoklu Touch):
--    - Tüm tıklamalar eşit paylaşılır
--    - Örn: 3 affiliate tıklaması → her birine %33
--    - multi_touch_behavior: ALL
--
-- 5. TIME_DECAY:
--    - Son tıklamalara daha fazla ağırlık
--    - Zaman bazlı azalan pay
--    - multi_touch_behavior: ALL
-- =============================================
