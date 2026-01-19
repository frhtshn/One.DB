CREATE VIEW catalog.v_daily_try_rates_nearest AS
SELECT
    d::date AS rate_date,
    r.quote_currency,
    r.rate
FROM generate_series(
        (SELECT MIN(rate_date) FROM catalog.currency_rates),
        (SELECT MAX(rate_date) FROM catalog.currency_rates),
        interval '1 day'
     ) d
JOIN LATERAL (
    SELECT rate, quote_currency
    FROM catalog.v_daily_try_rates r
    WHERE r.quote_currency = quote_currency
    ORDER BY ABS(r.rate_date - d)
    LIMIT 1
) r ON true;

