DROP TABLE IF EXISTS auth.player_credentials CASCADE;

CREATE TABLE auth.player_credentials (
    id bigserial PRIMARY KEY,
    player_id bigint NOT NULL,
    password_hash text NOT NULL,
    password_salt text NOT NULL,
    two_factor_enabled boolean NOT NULL DEFAULT false,
    two_factor_key varchar(256),
    payment_two_factor_enabled boolean NOT NULL DEFAULT false,
    payment_two_factor_key varchar(256),
    access_failed_count integer NOT NULL DEFAULT 0,
    lockout_enabled boolean NOT NULL DEFAULT false,
    lockout_end_at timestamp without time zone,
    last_password_change_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);
