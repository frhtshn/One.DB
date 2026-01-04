DROP TABLE IF EXISTS security.provider_secrets CASCADE;

CREATE TABLE security.provider_secrets (
    id bigserial PRIMARY KEY,
    provider_id bigint NOT NULL,
    secret_type varchar(50) NOT NULL,
    secret_value text NOT NULL,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    rotated_at timestamp without time zone
);
