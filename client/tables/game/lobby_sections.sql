-- =============================================
-- Tablo: game.lobby_sections
-- Açıklama: Oyun lobi bölüm tanımları
-- Ana sayfa ve lobi ekranında görünen oyun bölümleri
-- section_type: manual = elle seçim, auto_* = backend kural tabanlı
-- =============================================

DROP TABLE IF EXISTS game.lobby_sections CASCADE;

CREATE TABLE game.lobby_sections (
    id            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code          VARCHAR(100) NOT NULL UNIQUE,                     -- featured, new_games, hot_games, jackpots, live_casino, table_games, slots
    section_type  VARCHAR(30)  NOT NULL DEFAULT 'manual',           -- manual, auto_new, auto_popular, auto_jackpot, auto_top_rated
    max_items     SMALLINT     NOT NULL DEFAULT 20,                 -- Maksimum gösterilecek oyun sayısı
    display_order SMALLINT     NOT NULL DEFAULT 0,                  -- Lobi sayfasında sıralama
    link_url      VARCHAR(500),                                      -- "Tümünü Gör" linki
    is_active     BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    created_by    BIGINT,
    updated_by    BIGINT
);

COMMENT ON TABLE game.lobby_sections IS 'Game lobby section definitions. section_type controls content management: manual = BO curated via lobby_section_games, auto_* = backend auto-populated from game catalog rules. Translations in lobby_section_translations.';
