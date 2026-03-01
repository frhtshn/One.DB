-- =============================================
-- Tablo: game.lobby_section_games
-- Açıklama: Lobi bölümü oyun eşleştirmesi
-- Manuel küratörlük: hangi oyunun hangi bölümde yer aldığı
-- game_id: core DB oyun kataloğu (cross-DB, backend doğrular)
-- =============================================

DROP TABLE IF EXISTS game.lobby_section_games CASCADE;

CREATE TABLE game.lobby_section_games (
    id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    lobby_section_id BIGINT   NOT NULL,                             -- FK: game.lobby_sections(id) ON DELETE CASCADE
    game_id          BIGINT   NOT NULL,                             -- Core DB oyun ID (backend doğrulamalı, cross-DB FK yok)
    display_order    SMALLINT NOT NULL DEFAULT 0,                   -- Bölüm içi sıralama
    is_active        BOOLEAN  NOT NULL DEFAULT TRUE,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by       BIGINT,
    updated_by       BIGINT,

    CONSTRAINT uq_lobby_section_game UNIQUE (lobby_section_id, game_id)
);

COMMENT ON TABLE game.lobby_section_games IS 'Manual curation: game assignments to lobby sections with ordering. Only used when section_type = manual. game_id references core DB game catalog (validated by backend, no FK). FK to lobby_sections in tenant/constraints/content.sql.';
