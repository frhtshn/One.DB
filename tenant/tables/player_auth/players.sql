DROP TABLE IF EXISTS auth.players CASCADE;

CREATE TABLE auth.players (
    id bigserial PRIMARY KEY,
    username varchar(150) NOT NULL,
    email_encrypted BYTEA NOT NULL,
    email_hash BYTEA NOT NULL,
    status smallint NOT NULL DEFAULT 1,
    registered_at timestamp without time zone NOT NULL DEFAULT now(),
    last_login_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);

-- CREATE INDEX idx_players_email_hash ON auth.players USING btree(email_hash);
