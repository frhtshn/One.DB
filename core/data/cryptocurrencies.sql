INSERT INTO catalog.cryptocurrencies (symbol, name, name_full, is_active, sort_order) VALUES
('BTC', 'Bitcoin', 'Bitcoin', true, 1),
('ETH', 'Ethereum', 'Ethereum', true, 2),
('LTC', 'Litecoin', 'Litecoin', true, 3),
('XRP', 'Ripple', 'Ripple', true, 4),
('ADA', 'Cardano', 'Cardano', true, 5),
('SOL', 'Solana', 'Solana', true, 6)
ON CONFLICT (symbol) DO NOTHING;
