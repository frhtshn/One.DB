DROP TABLE IF EXISTS catalog.currencies CASCADE;

CREATE TABLE catalog.currencies (
    currency_code CHAR(3) PRIMARY KEY,     -- ISO 4217
    currency_name VARCHAR(100) NOT NULL,
    symbol VARCHAR(10),
    numeric_code SMALLINT,                  
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

