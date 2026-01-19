DROP TABLE IF EXISTS finance.currency_rates CASCADE;

CREATE TABLE finance.currency_rates (
    id BIGSERIAL PRIMARY KEY,

    provider VARCHAR(30) NOT NULL,          -- currencylayer, fixer, ecb
    provider_base_currency CHAR(3) NOT NULL, -- USD / EUR

    target_currency CHAR(3) NOT NULL,

    rate NUMERIC(18,8) NOT NULL,

    rate_timestamp TIMESTAMP WITHOUT TIME ZONE NOT NULL, -- provider zamanı
    fetched_at TIMESTAMP WITHOUT TIME ZONE NOT NULL,     -- API çağrı zamanı

    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),

    UNIQUE (
        provider,
        provider_base_currency,
        target_currency,
        rate_timestamp
    )
);
