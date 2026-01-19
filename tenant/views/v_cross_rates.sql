CREATE VIEW finance.v_cross_rates AS
SELECT
    r1.rate_date,
    r1.quote_currency AS from_currency,
    r2.quote_currency AS to_currency,
    r2.rate / r1.rate AS rate
FROM finance.v_daily_base_rates r1
JOIN finance.v_daily_base_rates r2
  ON r1.rate_date = r2.rate_date;

