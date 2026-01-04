DROP TABLE IF EXISTS catalog.countries CASCADE;

CREATE TABLE catalog.countries (
    country_code character(2) PRIMARY KEY,
    country_code_a3 character(3) NOT NULL UNIQUE,
    country_name varchar(100) NOT NULL
);
