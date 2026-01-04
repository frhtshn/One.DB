DROP TABLE IF EXISTS catalog.currencies CASCADE;

CREATE TABLE catalog.currencies (
    currency_code character(3) PRIMARY KEY,
    currency_name varchar(100) NOT NULL,
    symbol varchar(10),
    "precision" smallint NOT NULL DEFAULT 2,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);
