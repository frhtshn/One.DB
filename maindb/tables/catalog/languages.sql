DROP TABLE IF EXISTS catalog.languages CASCADE;

CREATE TABLE catalog.languages (
    language_code character(2) PRIMARY KEY,
    language_name varchar(100) NOT NULL,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp without time zone NOT NULL DEFAULT now()
);
