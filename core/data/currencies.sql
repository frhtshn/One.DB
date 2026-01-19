INSERT INTO catalog.currencies (currency_code, currency_name, symbol, is_active) VALUES
('USD', 'US Dollar', '$', true),
('EUR', 'Euro', '€', true),
('GBP', 'British Pound', '£', true),
('TRY', 'Turkish Lira', '₺', true),
('CAD', 'Canadian Dollar', 'C$', true),
('AUD', 'Australian Dollar', 'A$', true),
('SEK', 'Swedish Krona', 'kr', true),
('NOK', 'Norwegian Krone', 'kr', true),
('PLN', 'Polish Zloty', 'zł', true),
('CZK', 'Czech Koruna', 'Kč', true),
('HUF', 'Hungarian Forint', 'Ft', true),
('RUB', 'Russian Ruble', '₽', true),
('CNY', 'Chinese Yuan', '¥', true),
('INR', 'Indian Rupee', '₹', true),
('BRL', 'Brazilian Real', 'R$', true),
('MXN', 'Mexican Peso', '$', true)
ON CONFLICT (currency_code) DO NOTHING;
