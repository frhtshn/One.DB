-- =============================================
-- Player Classification (Oyuncu Sınıflandırması)
-- Oyuncunun hangi kategori ve gruba ait olduğu
-- Bir oyuncu bir kategoride, birden fazla grupta olabilir
-- =============================================

DROP TABLE IF EXISTS auth.player_classification CASCADE;

CREATE TABLE auth.player_classification (
    id bigserial PRIMARY KEY,
    player_id bigint NOT NULL,                    -- Oyuncu ID
    player_group_id bigint,                       -- Bağlı grup (opsiyonel)
    player_category_id bigint,                    -- Bağlı kategori (opsiyonel)
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);

COMMENT ON TABLE auth.player_classification IS 'Player classification assignments linking players to categories and groups for targeting';
