DROP TABLE IF EXISTS catalog.currencies CASCADE;

CREATE TABLE catalog.currencies (
    currency_code character(3) PRIMARY KEY,
    currency_name varchar(100) NOT NULL,
    symbol varchar(10),
    is_active boolean NOT NULL DEFAULT true
);
