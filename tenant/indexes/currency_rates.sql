CREATE UNIQUE INDEX uq_tenant_currency_rate
ON finance.currency_rates
(
    base_currency,
    quote_currency,
    rate_date,
    source
);

