DROP TABLE IF EXISTS finance.currency_rates_latest CASCADE;

CREATE TABLE finance.currency_rates_latest (
    provider VARCHAR(30) NOT NULL,
    provider_base_currency CHAR(3) NOT NULL,
    target_currency CHAR(3) NOT NULL,

    rate NUMERIC(18,8) NOT NULL,
    rate_timestamp TIMESTAMP WITHOUT TIME ZONE NOT NULL,

    PRIMARY KEY (provider, provider_base_currency, target_currency)
);
