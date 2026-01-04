DROP TABLE IF EXISTS auth.player_classification CASCADE;

CREATE TABLE auth.player_classification (
    id bigserial PRIMARY KEY,
    player_id bigint NOT NULL,
    player_group_id bigint,
    player_category_id bigint,
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);
