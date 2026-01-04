DROP TABLE IF EXISTS core.tenant_languages CASCADE;

CREATE TABLE core.tenant_languages (
    id bigserial PRIMARY KEY,
    tenant_id bigint NOT NULL,
    language_code character(2) NOT NULL,
    is_enabled boolean NOT NULL DEFAULT true,
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);
