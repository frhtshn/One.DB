DROP TABLE IF EXISTS profile.player_identity CASCADE;

CREATE TABLE profile.player_identity (
    id bigserial PRIMARY KEY,
    player_id bigint NOT NULL,
    identity_no BYTEA,
    identity_no_hash BYTEA,  -- Searchable
    identity_confirmed boolean NOT NULL DEFAULT false,
    verified_at timestamp without time zone
);

-- CREATE INDEX idx_player_identity_no_hash ON profile.player_identity USING btree(identity_no_hash);
