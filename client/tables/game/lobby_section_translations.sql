-- =============================================
-- Tablo: game.lobby_section_translations
-- Açıklama: Lobi bölümü başlık ve alt başlık çevirileri
-- FK: lobby_section_id → game.lobby_sections(id)
-- =============================================

DROP TABLE IF EXISTS game.lobby_section_translations CASCADE;

CREATE TABLE game.lobby_section_translations (
    id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    lobby_section_id BIGINT       NOT NULL,                         -- FK: game.lobby_sections(id) ON DELETE CASCADE
    language_code    VARCHAR(5)   NOT NULL,
    title            VARCHAR(200) NOT NULL,                         -- Bölüm başlığı (örn. "Öne Çıkan Oyunlar")
    subtitle         VARCHAR(500),                                   -- İsteğe bağlı alt başlık

    CONSTRAINT uq_lobby_section_translation UNIQUE (lobby_section_id, language_code)
);

COMMENT ON TABLE game.lobby_section_translations IS 'Multilingual title and subtitle for lobby sections. FK to lobby_sections defined in tenant/constraints/content.sql.';
