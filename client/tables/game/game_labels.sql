-- =============================================
-- Tablo: game.game_labels
-- Açıklama: Oyun kartı rozet/etiket yönetimi
-- Oyun kartlarında görünen "Yeni", "Sıcak", "Özel" gibi rozetler
-- game_id: core DB oyun kataloğu (cross-DB, backend doğrular)
-- =============================================

DROP TABLE IF EXISTS game.game_labels CASCADE;

CREATE TABLE game.game_labels (
    id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    game_id      BIGINT       NOT NULL,                             -- Core DB oyun ID (backend doğrulamalı, cross-DB FK yok)
    label_type   VARCHAR(30)  NOT NULL,                             -- new, hot, exclusive, jackpot, featured, top, live, recommended
    label_color  VARCHAR(7),                                        -- Hex renk kodu (#RRGGBB)
    expires_at   TIMESTAMPTZ,                                       -- NULL = kalıcı
    is_active    BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    created_by   BIGINT,
    updated_by   BIGINT,

    CONSTRAINT uq_game_label UNIQUE (game_id, label_type)
);

COMMENT ON TABLE game.game_labels IS 'Badge/label assignments for game cards. Supports time-limited labels (expires_at) and permanent badges. UNIQUE per game+label_type. game_id references core DB game catalog (validated by backend, no FK).';
