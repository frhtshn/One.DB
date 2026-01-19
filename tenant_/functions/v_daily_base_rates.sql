CREATE VIEW finance.v_daily_base_rates AS
SELECT DISTINCT ON (rate_date, quote_currency)
       rate_date,
       quote_currency,
       rate
FROM finance.currency_rates
ORDER BY rate_date, quote_currency, fetched_at DESC;

