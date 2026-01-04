DROP TABLE IF EXISTS core.tenant_games CASCADE;

CREATE TABLE core.tenant_games (
    id bigserial PRIMARY KEY,
    tenant_id bigint NOT NULL,
    game_id bigint NOT NULL,
    is_enabled boolean NOT NULL DEFAULT true,
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);
