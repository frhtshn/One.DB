DROP TABLE IF EXISTS catalog.provider_types CASCADE;

CREATE TABLE catalog.provider_types (
    id bigserial PRIMARY KEY,
    provider_type_code varchar(30) NOT NULL,
    provider_type_name varchar(100) NOT NULL,
    created_at timestamp without time zone NOT NULL DEFAULT now()
);
