DROP TABLE IF EXISTS catalog.providers CASCADE;

CREATE TABLE catalog.providers (
    id bigserial PRIMARY KEY,
    provider_type_id bigint NOT NULL,
    provider_code varchar(50) NOT NULL,
    provider_name varchar(255) NOT NULL,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp without time zone NOT NULL DEFAULT now()
);
