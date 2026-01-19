CREATE TABLE catalog.staging_currency_rates (
    base_currency CHAR(3),
    quote_currency CHAR(3),
    rate NUMERIC(18,8),
    rate_date DATE,
    source VARCHAR(50),
    created_at TIMESTAMP
);

