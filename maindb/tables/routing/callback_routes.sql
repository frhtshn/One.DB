DROP TABLE IF EXISTS routing.callback_routes CASCADE;

CREATE TABLE routing.callback_routes (
    id bigserial PRIMARY KEY,
    provider_id bigint NOT NULL,
    tenant_id bigint NOT NULL,
    route_key varchar(100) NOT NULL,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp without time zone NOT NULL DEFAULT now()
);
