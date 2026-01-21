INSERT INTO catalog.transaction_types
(code, category, product, is_bonus, is_free, is_rollback, is_winning, is_reportable, description)
VALUES

-- BET TRANSACTIONS
('sports.bet', 'bet', 'sports', false, false, false, false, true, 'Sports bet wager'),
('free.sports.bet', 'bet', 'sports', true,  true,  false, false, true, 'Free sports bet'),
('casino.bet', 'bet', 'casino', false, false, false, false, true, 'Casino bet'),
('live.casino.bet', 'bet', 'casino', false, false, false, false, true, 'Live casino bet'),
('poker.bet', 'bet', 'poker', false, false, false, false, true, 'Poker bet'),
('virtual.sports.bet', 'bet', 'sports', false, false, false, false, true, 'Virtual sports bet'),
('horse.greyhound.bet', 'bet', 'sports', false, false, false, false, true, 'Horse/Greyhound bet'),
-- WIN TRANSACTIONS
('sports.bet.win', 'win', 'sports', false,  false, false, true,  true, 'Sports bet win'),
('free.sports.win', 'win', 'sports', true,  true,  false, true,  true, 'Free sports bet win'),
('casino.bet.win', 'win', 'casino', false,  false, false, true,  true, 'Casino bet win'),
('live.casino.win', 'win', 'casino', false,  false, false, true,  true, 'Live casino bet win'),
('poker.bet.win', 'win', 'poker', false,  false, false, true,  true, 'Poker bet win'),
('virtual.sports.win', 'win', 'sports', false,  false, false, true,  true, 'Virtual sports bet win'),
('horse.greyhound.win', 'win', 'sports', false,  false, false, true,  true, 'Horse/Greyhound bet win'),
('casino.provider.bonus.win', 'win', 'casino', false,  false, false, true,  true, 'Casino provider bonus win'),
-- BONUS / ADJUSTMENT
('bonus.transaction', 'bonus', NULL, true,  false, false, false, true, 'Generic bonus'),
('casino.bonus.transaction', 'bonus', 'casino', true,  false, false, false, true, 'Casino bonus'),
('casino.claimed.bonus', 'bonus', 'casino', true,  false, false, false, true, 'Claimed casino bonus'),
('casino.bonus.forfeit', 'bonus', 'casino', true,  false, false, false, true, 'Casino bonus forfeit'),
('discount.transaction', 'bonus', NULL, true,  false, false, false, true, 'Discount'),
('adjustment', 'adjustment', NULL, false, false, false, false, true, 'Manual adjustment'),
('casino.adjustment', 'adjustment', 'casino', false, false, false, false, true, 'Casino adjustment'),
-- PAYMENT / TRANSFER
('payment.provider.transaction', 'payment', 'payment', false, false, false, false, true, 'Payment provider transaction'),
('manual.payment.transaction', 'payment', 'payment', false, false, false, false, true, 'Manual payment'),
('manual.fund.transfer', 'payment', 'payment', false, false, false, false, true, 'Manual fund transfer'),
('casino.transfer.funds', 'payment', 'casino', false, false, false, false, true, 'Casino fund transfer'),
-- ROLLBACK TYPES
('sports.bet.wager.rollback', 'bet', 'sports', false,  false, true,  false, true, 'Sports bet rollback'),
('sports.win.rollback', 'win', 'sports', false,  false, true,  false, true, 'Sports bet win rollback'),
('free.sports.win.rollback', 'win', 'sports', true,  true,  true,  false, true, 'Free sports bet win rollback'),
('free.sports.wager.rollback', 'bet', 'sports', true,  true,  true,  false, true, 'Free bet wager rollback'),
('casino.bonus.transaction.rollback', 'bonus', 'casino', true,  false, true,  false, true, 'Casino bonus rollback'),
('bonus.transaction.rollback', 'bonus', NULL, true,  false, true,  false, true, 'Bonus rollback'),
('discount.transaction.rollback', 'bonus', NULL, true,  false, true,  false, true, 'Discount rollback'),
('casino.adjustment.rollback', 'adjustment', 'casino', false,  false, true,  false, true, 'Casino adjustment rollback');
