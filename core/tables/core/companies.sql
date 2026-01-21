DROP TABLE IF EXISTS core.companies CASCADE;

CREATE TABLE core.companies (
    id bigserial PRIMARY KEY,
    company_code varchar(50) NOT NULL UNIQUE,
    company_name varchar(255) NOT NULL,
    status smallint NOT NULL DEFAULT 1,
    country_code character(2),
    timezone varchar(50),
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);

ALTER SEQUENCE core.companies_id_seq MINVALUE 0 RESTART WITH 0;
