-- =============================================
-- View: v_cross_rates
-- Çapraz kur hesaplaması
-- =============================================

CREATE VIEW finance.v_cross_rates AS
SELECT
    r1.rate_date,
    r1.target_currency AS from_currency,
    r2.target_currency AS to_currency,
    r2.rate / r1.rate AS rate
FROM finance.v_daily_base_rates r1
JOIN finance.v_daily_base_rates r2
  ON r1.rate_date = r2.rate_date;

COMMENT ON VIEW finance.v_cross_rates IS 'Cross currency rates calculated from base rates';
