DROP TABLE IF EXISTS auth.player_groups CASCADE;

CREATE TABLE auth.player_groups (
    id bigserial PRIMARY KEY,
    group_code varchar(50) NOT NULL,
    group_name varchar(100) NOT NULL,
    description varchar(255),
    created_at timestamp without time zone NOT NULL DEFAULT now()
);
