INSERT INTO catalog.transaction_types
(code, category, product, is_bonus, is_free, is_rollback, is_winning, description)
VALUES

-- BET TRANSACTIONS  
('sports_bet', 'bet', 'sports', false, false, false, false, 'Sports bet wager'),
('free_sports_bet', 'bet', 'sports', true,  true,  false, false, 'Free sports bet'),
('casino_bet', 'bet', 'casino', false, false, false, false, 'Casino bet'),
('live_casino_bet', 'bet', 'casino', false, false, false, false, 'Live casino bet'),
('poker_bet', 'bet', 'poker', false, false, false, false, 'Poker bet'),
('virtual_sports_bet', 'bet', 'sports', false, false, false, false, 'Virtual sports bet'),
('horse_greyhound_bet', 'bet', 'sports', false, false, false, false, 'Horse/Greyhound bet'),
-- WIN TRANSACTIONS
('sports_bet_win', 'win', 'sports', false,  false, false, true,  'Sports bet win'),
('free_sports_bet_win', 'win', 'sports', true,  true,  false, true,  'Free sports bet win'),
('casino_bet_win', 'win', 'casino', false,  false, false, true,  'Casino bet win'),
('live_casino_bet_win', 'win', 'casino', false,  false, false, true,  'Live casino bet win'),
('poker_bet_win', 'win', 'poker', false,  false, false, true,  'Poker bet win'),
('virtual_sports_bet_win', 'win', 'sports', false,  false, false, true,  'Virtual sports bet win'),
('horse_greyhound_bet_win', 'win', 'sports', false,  false, false, true,  'Horse/Greyhound bet win'),
('casino_provider_bonus_win', 'win', 'casino', false,  false, false, true,  'Casino provider bonus win'),
-- BONUS / ADJUSTMENT
('bonus_transaction', 'bonus', NULL, true,  false, false, false, 'Generic bonus'),
('casino_bonus_transaction', 'bonus', 'casino', true,  false, false, false, 'Casino bonus'),
('casino_claimed_bonus', 'bonus', 'casino', true,  false, false, false, 'Claimed casino bonus'),
('casino_bonus_forfeit', 'bonus', 'casino', true,  false, false, false, 'Casino bonus forfeit'),
('discount_transaction', 'bonus', NULL, true,  false, false, false, 'Discount'),
('adjustment', 'adjustment', NULL, false, false, false, false, 'Manual adjustment'),
('casino_adjustment', 'adjustment', 'casino', false, false, false, false, 'Casino adjustment'),
-- PAYMENT / TRANSFER
('payment_provider_transaction', 'payment', 'payment', false, false, false, false, 'Payment provider transaction'),
('manual_payment_transaction', 'payment', 'payment', false, false, false, false, 'Manual payment'),
('manual_fund_transfer', 'payment', 'payment', false, false, false, false, 'Manual fund transfer'),
('casino_transfer_funds', 'payment', 'casino', false, false, false, false, 'Casino fund transfer'),
-- ROLLBACK TYPES
('sports_bet_wager_rollback', 'bet', 'sports', true,  false, true,  false, 'Sports bet rollback'),
('sports_bet_win_rollback', 'win', 'sports', true,  false, true,  false, 'Sports bet win rollback'),
('free_sports_bet_win_rollback', 'win', 'sports', true,  true,  true,  false, 'Free sports bet win rollback'),
('free_sports_bet_wager_rollback', 'bet', 'sports', true,  true,  true,  false, 'Free bet wager rollback'),
('casino_bonus_transaction_rollback', 'bonus', 'casino', true,  false, true,  false, 'Casino bonus rollback'),
('bonus_transaction_rollback', 'bonus', NULL, true,  false, true,  false, 'Bonus rollback'),
('discount_transaction_rollback', 'bonus', NULL, true,  false, true,  false, 'Discount rollback'),
('casino_adjustment_rollback', 'adjustment', 'casino', true,  false, true,  false, 'Casino adjustment rollback');