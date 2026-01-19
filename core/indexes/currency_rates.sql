CREATE UNIQUE INDEX uq_currency_rate_day
ON catalog.currency_rates
(
    base_currency,
    quote_currency,
    rate_date,
    source
);

