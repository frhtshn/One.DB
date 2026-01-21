DROP TABLE IF EXISTS auth.player_credentials CASCADE;

CREATE TABLE auth.player_credentials (
    id bigserial PRIMARY KEY,
    player_id bigint NOT NULL,
    password VARCHAR(255) NOT NULL,  -- Argon2d hash (salt embedded)
    two_factor_enabled BOOLEAN NOT NULL DEFAULT false,
    two_factor_key BYTEA,  -- Encrypted
    payment_two_factor_enabled BOOLEAN NOT NULL DEFAULT false,
    payment_two_factor_key BYTEA,  -- Encrypted
    access_failed_count integer NOT NULL DEFAULT 0,
    lockout_enabled boolean NOT NULL DEFAULT false,
    lockout_end_at timestamp without time zone,
    last_password_change_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);
