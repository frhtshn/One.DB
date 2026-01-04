DROP TABLE IF EXISTS core.tenant_currencies CASCADE;

CREATE TABLE core.tenant_currencies (
    id bigserial PRIMARY KEY,
    tenant_id bigint NOT NULL,
    currency_code character(3) NOT NULL,
    is_enabled boolean NOT NULL DEFAULT true,
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);
