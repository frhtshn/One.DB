DROP TABLE IF EXISTS core.tenants CASCADE;

CREATE TABLE core.tenants (
    id bigserial PRIMARY KEY,
    company_id bigint NOT NULL,
    tenant_code varchar(50) NOT NULL UNIQUE,
    tenant_name varchar(255) NOT NULL,
    environment varchar(20) NOT NULL DEFAULT 'prod',
    status smallint NOT NULL DEFAULT 1,
    default_currency character(3),
    default_language character(2),
    default_country character(2),
    timezone varchar(50),
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
    --CONSTRAINT tenants_company_id_fkey FOREIGN KEY (company_id) REFERENCES core.companies(id)
);
