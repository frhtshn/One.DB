DROP TABLE IF EXISTS catalog.countries CASCADE;

CREATE TABLE catalog.countries (
    country_code character(2) PRIMARY KEY,
    country_name varchar(100) NOT NULL,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);
