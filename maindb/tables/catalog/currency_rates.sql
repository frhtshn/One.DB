DROP TABLE IF EXISTS catalog.currency_rates CASCADE;

CREATE TABLE catalog.currency_rates (
    id bigserial PRIMARY KEY,
    base_currency character(3) NOT NULL,
    quote_currency character(3) NOT NULL,
    rate numeric(18,8) NOT NULL,
    rate_date date NOT NULL,
    source varchar(50),
    created_at timestamp without time zone NOT NULL DEFAULT now()
);
