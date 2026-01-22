DROP TABLE IF EXISTS profile.player_profile CASCADE;

CREATE TABLE profile.player_profile (
    id bigserial PRIMARY KEY,
    player_id bigint NOT NULL,
    first_name BYTEA,
    first_name_hash BYTEA,  -- Searchable
    middle_name BYTEA,
    last_name BYTEA,
    last_name_hash BYTEA,  -- Searchable
    birth_date BYTEA,
    address BYTEA,
    phone BYTEA,
    phone_hash BYTEA,  -- Searchable
    gsm BYTEA,
    gsm_hash BYTEA,  -- Searchable
    country_code character(2),
    city varchar(100),
    gender smallint,
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);
