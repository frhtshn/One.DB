INSERT INTO catalog.transaction_types
(code, category, product, is_bonus, is_free, is_rollback, is_winning, description)
VALUES

-- BET TRANSACTIONS  
('SPORTS_BET', 'BET', 'SPORTS', false, false, false, false, 'Sports bet wager'),
('FREE_SPORTS_BET', 'BET', 'SPORTS', true,  true,  false, false, 'Free sports bet'),
('CASINO_BET', 'BET', 'CASINO', false, false, false, false, 'Casino bet'),
('LIVE_CASINO_BET', 'BET', 'CASINO', false, false, false, false, 'Live casino bet'),
('POKER_BET', 'BET', 'POKER', false, false, false, false, 'Poker bet'),
('VIRTUAL_SPORTS_BET', 'BET', 'SPORTS', false, false, false, false, 'Virtual sports bet'),
('HORSE_GREYHOUND_BET', 'BET', 'SPORTS', false, false, false, false, 'Horse/Greyhound bet'),

-- WIN TRANSACTIONS
('SPORTS_BET_WIN', 'WIN', 'SPORTS', true,  false, false, true,  'Sports bet win'),
('FREE_SPORTS_BET_WIN', 'WIN', 'SPORTS', true,  true,  false, true,  'Free sports bet win'),
('CASINO_BET_WIN', 'WIN', 'CASINO', true,  false, false, true,  'Casino bet win'),
('LIVE_CASINO_BET_WIN', 'WIN', 'CASINO', true,  false, false, true,  'Live casino bet win'),
('POKER_BET_WIN', 'WIN', 'POKER', true,  false, false, true,  'Poker bet win'),
('VIRTUAL_SPORTS_BET_WIN', 'WIN', 'SPORTS', true,  false, false, true,  'Virtual sports bet win'),
('HORSE_GREYHOUND_BET_WIN', 'WIN', 'SPORTS', true,  false, false, true,  'Horse/Greyhound bet win'),
('CASINO_PROVIDER_BONUS_WIN', 'WIN', 'CASINO', true,  false, false, true,  'Casino provider bonus win'),

-- BONUS / ADJUSTMENT
('BONUS_TRANSACTION', 'BONUS', NULL, true,  false, false, false, 'Generic bonus'),
('CASINO_BONUS_TRANSACTION', 'BONUS', 'CASINO', true,  false, false, false, 'Casino bonus'),
('CASINO_CLAIMED_BONUS', 'BONUS', 'CASINO', true,  false, false, false, 'Claimed casino bonus'),
('CASINO_BONUS_FORFEIT', 'BONUS', 'CASINO', true,  false, false, false, 'Casino bonus forfeit'),
('DISCOUNT_TRANSACTION', 'BONUS', NULL, true,  false, false, false, 'Discount'),
('ADJUSTMENT', 'ADJUSTMENT', NULL, false, false, false, false, 'Manual adjustment'),
('CASINO_ADJUSTMENT', 'ADJUSTMENT', 'CASINO', false, false, false, false, 'Casino adjustment'),

-- PAYMENT / TRANSFER
('PAYMENT_PROVIDER_TRANSACTION', 'PAYMENT', 'PAYMENT', false, false, false, false, 'Payment provider transaction'),
('MANUAL_PAYMENT_TRANSACTION', 'PAYMENT', 'PAYMENT', false, false, false, false, 'Manual payment'),
('MANUAL_FUND_TRANSFER', 'PAYMENT', 'PAYMENT', false, false, false, false, 'Manual fund transfer'),
('CASINO_TRANSFER_FUNDS', 'PAYMENT', 'CASINO', false, false, false, false, 'Casino fund transfer'),

-- ROLLBACK TYPES
('SPORTS_BET_WAGER_ROLLBACK', 'BET', 'SPORTS', true,  false, true,  false, 'Sports bet rollback'),
('SPORTS_BET_WIN_ROLLBACK', 'WIN', 'SPORTS', true,  false, true,  false, 'Sports bet win rollback'),
('FREE_SPORTS_BET_WIN_ROLLBACK', 'WIN', 'SPORTS', true,  true,  true,  false, 'Free sports bet win rollback'),
('FREE_SPORTS_BET_WAGER_ROLLBACK', 'BET', 'SPORTS', true,  true,  true,  false, 'Free bet wager rollback'),
('CASINO_BONUS_TRANSACTION_ROLLBACK', 'BONUS', 'CASINO', true,  false, true,  false, 'Casino bonus rollback'),
('BONUS_TRANSACTION_ROLLBACK', 'BONUS', NULL, true,  false, true,  false, 'Bonus rollback'),
('DISCOUNT_TRANSACTION_ROLLBACK', 'BONUS', NULL, true,  false, true,  false, 'Discount rollback'),
('CASINO_ADJUSTMENT_ROLLBACK', 'ADJUSTMENT', 'CASINO', true,  false, true,  false, 'Casino adjustment rollback');
