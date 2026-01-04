DROP TABLE IF EXISTS core.tenant_providers CASCADE;

CREATE TABLE core.tenant_providers (
    id bigserial PRIMARY KEY,
    tenant_id bigint NOT NULL,
    provider_id bigint NOT NULL,
    mode varchar(20) NOT NULL DEFAULT 'real',
    is_enabled boolean NOT NULL DEFAULT true,
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);
