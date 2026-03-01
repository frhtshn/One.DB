-- =============================================
-- Tablo: presentation.announcement_bars
-- Açıklama: Site duyuru çubukları
-- Sitenin üst kısmında görünen zamanlı ve hedeflenmiş duyurular
-- Hem misafir hem kayıtlı kullanıcılara yönelik
-- =============================================

DROP TABLE IF EXISTS presentation.announcement_bars CASCADE;

CREATE TABLE presentation.announcement_bars (
    id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code            VARCHAR(100)  NOT NULL UNIQUE,                  -- İnsan okunabilir tanımlayıcı
    starts_at       TIMESTAMPTZ,                                     -- NULL = hemen başlar
    ends_at         TIMESTAMPTZ,                                     -- NULL = süresiz
    target_audience VARCHAR(20)   NOT NULL DEFAULT 'all',           -- all, guest, logged_in
    country_codes   VARCHAR(2)[]  NOT NULL DEFAULT '{}',            -- Boş dizi = tüm ülkeler
    priority        SMALLINT      NOT NULL DEFAULT 0,               -- Yüksek öncelik üstte gösterilir
    bg_color        VARCHAR(7),                                      -- Hex renk kodu (#RRGGBB)
    text_color      VARCHAR(7),                                      -- Hex renk kodu
    is_dismissible  BOOLEAN       NOT NULL DEFAULT TRUE,            -- Kullanıcı kapatabilir mi?
    is_active       BOOLEAN       NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    created_by      BIGINT,
    updated_by      BIGINT
);

COMMENT ON TABLE presentation.announcement_bars IS 'Scheduled and targeted announcement bars shown at top of site. Supports time-based scheduling, audience targeting (all/guest/logged_in), and geo-targeting via country_codes. Translations stored in announcement_bar_translations.';
