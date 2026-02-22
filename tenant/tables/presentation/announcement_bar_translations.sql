-- =============================================
-- Tablo: presentation.announcement_bar_translations
-- Açıklama: Duyuru çubuğu çevirileri
-- Dil bazlı metin ve link bilgileri
-- FK: announcement_bar_id → presentation.announcement_bars(id)
-- =============================================

DROP TABLE IF EXISTS presentation.announcement_bar_translations CASCADE;

CREATE TABLE presentation.announcement_bar_translations (
    id                  BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    announcement_bar_id BIGINT       NOT NULL,                      -- FK: presentation.announcement_bars(id) ON DELETE CASCADE
    language_code       VARCHAR(5)   NOT NULL,                      -- en, tr, de vb.
    text                TEXT         NOT NULL,                      -- Çubuk metni
    link_url            VARCHAR(500),                               -- İsteğe bağlı tıklanabilir link
    link_label          VARCHAR(100),                               -- Link butonu etiketi

    CONSTRAINT uq_announcement_bar_translation UNIQUE (announcement_bar_id, language_code)
);

COMMENT ON TABLE presentation.announcement_bar_translations IS 'Language-specific text and link content for announcement bars. FK to announcement_bars defined in tenant/constraints/content.sql.';
