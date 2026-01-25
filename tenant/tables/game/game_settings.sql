DROP TABLE IF EXISTS game.game_settings CASCADE;

CREATE TABLE game.game_settings (
    id bigserial PRIMARY KEY,

    -- Core DB'den denormalize edilmiş alanlar (catalog.games + catalog.providers)
    game_id bigint NOT NULL,
    game_code varchar(100) NOT NULL,
    game_name varchar(255) NOT NULL,
    provider_id bigint NOT NULL,
    provider_code varchar(50) NOT NULL,

    -- Tenant'a özel görünüm ayarları
    display_order int,
    is_visible boolean NOT NULL DEFAULT true,
    is_featured boolean NOT NULL DEFAULT false,

    -- Tenant'a özel özelleştirmeler
    custom_name varchar(255),
    custom_thumbnail_url varchar(500),

    -- Tenant'a özel oyun limitleri
    min_bet decimal(18,2),
    max_bet decimal(18,2),

    -- Ek metadata
    tags jsonb,
    metadata jsonb,

    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);
