-- =============================================
-- View: v_daily_base_rates
-- Her gün için son kur değerlerini döner
-- =============================================

DROP VIEW IF EXISTS finance.v_daily_base_rates CASCADE;

CREATE VIEW finance.v_daily_base_rates AS
SELECT DISTINCT ON (rate_timestamp::date, target_currency)
       rate_timestamp::date AS rate_date,
       target_currency,
       rate
FROM finance.currency_rates
ORDER BY rate_timestamp::date, target_currency, fetched_at DESC;

COMMENT ON VIEW finance.v_daily_base_rates IS 'Daily base currency rates - returns latest rate per day and currency';
