DROP TABLE IF EXISTS core.tenant_payment_methods CASCADE;

CREATE TABLE core.tenant_payment_methods (
    id bigserial PRIMARY KEY,
    tenant_id bigint NOT NULL,
    payment_method_id bigint NOT NULL,
    is_enabled boolean NOT NULL DEFAULT true,
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);
