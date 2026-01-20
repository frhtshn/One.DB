DROP TABLE IF EXISTS profile.player_profile CASCADE;

CREATE TABLE profile.player_profile (
    id bigserial PRIMARY KEY,
    player_id bigint NOT NULL,
    first_name bytea,
    middle_name bytea,
    last_name bytea,
    birth_date bytea,
    address bytea,
    phone bytea,
    gsm bytea,
    country_code character(2),
    city varchar(100),
    gender smallint,
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);
