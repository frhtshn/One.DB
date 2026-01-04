DROP TABLE IF EXISTS core.tenant_settings CASCADE;

CREATE TABLE core.tenant_settings (
    id bigserial PRIMARY KEY,
    tenant_id bigint NOT NULL,
    setting_key varchar(100) NOT NULL,
    setting_value jsonb NOT NULL,
    description varchar(255),
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);
