DROP TABLE IF EXISTS catalog.currency_rates CASCADE;

CREATE TABLE catalog.currency_rates (
    id BIGSERIAL PRIMARY KEY,

    base_currency CHAR(3) NOT NULL,
    quote_currency CHAR(3) NOT NULL,

    rate NUMERIC(18,8) NOT NULL,

    rate_date DATE NOT NULL,               -- iş günü bazlı kur
    source VARCHAR(50) NOT NULL,            -- mssql, ecb, fixer, manual vs.

    created_at TIMESTAMP NOT NULL DEFAULT now(),
);

