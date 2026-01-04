DROP TABLE IF EXISTS profile.player_identity CASCADE;

CREATE TABLE profile.player_identity (
    id bigserial PRIMARY KEY,
    player_id bigint NOT NULL,
    identity_no bytea,
    identity_confirmed boolean NOT NULL DEFAULT false,
    verified_at timestamp without time zone
);
