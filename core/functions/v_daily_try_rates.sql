CREATE VIEW catalog.v_daily_try_rates AS
SELECT DISTINCT ON (rate_date, quote_currency)
       rate_date,
       quote_currency,
       rate
FROM catalog.currency_rates
WHERE base_currency = 'TRY'
ORDER BY rate_date, quote_currency, created_at DESC;

