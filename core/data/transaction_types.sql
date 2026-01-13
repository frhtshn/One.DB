INSERT INTO catalog.transaction_types
(code, category, product, is_bonus, is_free, is_rollback, is_winning, description)
VALUES

-- BET TRANSACTIONS  
('SPORTS_BET', 'BET', 'SPORTS', false, false, false, false, 'Sports bet wager'),
('FREE_SPORTS_BET', 'BET', 'SPORTS', true, true, false, false, 'Free sports bet'),
('CASINO_BET', 'BET', 'CASINO', false, false, false, false, 'Casino bet'),
('LIVE_CASINO_BET', 'BET', 'CASINO', false, false, false, false, 'Live casino bet'),
('POKER_BET', 'BET', 'POKER', false, false, false, false, 'Poker bet'),
('VIRTUAL_SPORTS_BET', 'BET', 'SPORTS', false, false, false, false, 'Virtual sports bet'),
('HORSE_GREYHOUND_BET', 'BET', 'SPORTS', false, false, false, false, 'Horse/Greyhound bet');

-- WIN TRANSACTIONS
('SPORTS_BET_WIN', 'WIN', 'SPORTS', true, 'Sports bet win'),
('FREE_SPORTS_BET_WIN', 'WIN', 'SPORTS', true, 'Free sports bet win'),
('CASINO_BET_WIN', 'WIN', 'CASINO', true, 'Casino bet win'),
('LIVE_CASINO_BET_WIN', 'WIN', 'CASINO', true, 'Live casino bet win'),
('POKER_BET_WIN', 'WIN', 'POKER', true, 'Poker bet win'),
('VIRTUAL_SPORTS_BET_WIN', 'WIN', 'SPORTS', true, 'Virtual sports bet win'),
('HORSE_GREYHOUND_BET_WIN', 'WIN', 'SPORTS', true, 'Horse/Greyhound bet win'),
('CASINO_PROVIDER_BONUS_WIN', 'WIN', 'CASINO', true, 'Casino provider bonus win');

-- BONUS / ADJUSTMENT
('BONUS_TRANSACTION', 'BONUS', null, true, 'Generic bonus'),
('CASINO_BONUS_TRANSACTION', 'BONUS', 'CASINO', true, 'Casino bonus'),
('CASINO_CLAIMED_BONUS', 'BONUS', 'CASINO', true, 'Claimed casino bonus'),
('CASINO_BONUS_FORFEIT', 'BONUS', 'CASINO', true, 'Casino bonus forfeit'),
('DISCOUNT_TRANSACTION', 'BONUS', null, true, 'Discount'),
('ADJUSTMENT', 'ADJUSTMENT', null, false, 'Manual adjustment'),
('CASINO_ADJUSTMENT', 'ADJUSTMENT', 'CASINO', false, 'Casino adjustment');

-- PAYMENT / TRANSFER
('PAYMENT_PROVIDER_TRANSACTION', 'PAYMENT', 'PAYMENT', 'Payment provider transaction'),
('MANUAL_PAYMENT_TRANSACTION', 'PAYMENT', 'PAYMENT', 'Manual payment'),
('MANUAL_FUND_TRANSFER', 'PAYMENT', 'PAYMENT', 'Manual fund transfer'),
('CASINO_TRANSFER_FUNDS', 'PAYMENT', 'CASINO', 'Casino fund transfer');

-- ROLLBACK TYPES
('SPORTS_BET_WAGER_ROLLBACK', 'BET', 'SPORTS', true, false, 'Sports bet rollback'),
('SPORTS_BET_WIN_ROLLBACK', 'WIN', 'SPORTS', true, false, 'Sports bet win rollback'),
('FREE_SPORTS_BET_WIN_ROLLBACK', 'WIN', 'SPORTS', true, false, 'Free sports bet win rollback'),
('FREE_SPORTS_BET_WAGER_ROLLBACK', 'BET', 'SPORTS', true, false, 'Free bet wager rollback'),
('CASINO_BONUS_TRANSACTION_ROLLBACK', 'BONUS', 'CASINO', true, false, 'Casino bonus rollback'),
('BONUS_TRANSACTION_ROLLBACK', 'BONUS', null, true, false, 'Bonus rollback'),
('DISCOUNT_TRANSACTION_ROLLBACK', 'BONUS', null, true, false, 'Discount rollback'),
('CASINO_ADJUSTMENT_ROLLBACK', 'ADJUSTMENT', 'CASINO', true, false, 'Casino adjustment rollback');

