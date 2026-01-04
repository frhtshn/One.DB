DROP TABLE IF EXISTS catalog.games CASCADE;

CREATE TABLE catalog.games (
    id bigserial PRIMARY KEY,
    provider_id bigint NOT NULL,
    game_code varchar(100) NOT NULL,
    game_name varchar(255) NOT NULL,
    game_type varchar(50),
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);
