DROP TABLE IF EXISTS routing.provider_endpoints CASCADE;

CREATE TABLE routing.provider_endpoints (
    id bigserial PRIMARY KEY,
    provider_id bigint NOT NULL,
    gateway_code varchar(50) NOT NULL,
    endpoint_type varchar(50) NOT NULL,
    endpoint_url text NOT NULL,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);
