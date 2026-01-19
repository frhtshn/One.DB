INSERT INTO catalog.transaction.types
(code, category, product, is.bonus, is.free, is.rollback, is.winning, description)
VALUES

-- BET TRANSACTIONS  
('sports.bet', 'bet', 'sports', false, false, false, false, 'Sports bet wager'),
('free.sports.bet', 'bet', 'sports', true,  true,  false, false, 'Free sports bet'),
('casino.bet', 'bet', 'casino', false, false, false, false, 'Casino bet'),
('live.casino.bet', 'bet', 'casino', false, false, false, false, 'Live casino bet'),
('poker.bet', 'bet', 'poker', false, false, false, false, 'Poker bet'),
('virtual.sports.bet', 'bet', 'sports', false, false, false, false, 'Virtual sports bet'),
('horse.greyhound.bet', 'bet', 'sports', false, false, false, false, 'Horse/Greyhound bet'),
-- WIN TRANSACTIONS
('sports.bet.win', 'win', 'sports', false,  false, false, true,  'Sports bet win'),
('free.sports.win', 'win', 'sports', true,  true,  false, true,  'Free sports bet win'),
('casino.bet.win', 'win', 'casino', false,  false, false, true,  'Casino bet win'),
('live.casino.win', 'win', 'casino', false,  false, false, true,  'Live casino bet win'),
('poker.bet.win', 'win', 'poker', false,  false, false, true,  'Poker bet win'),
('virtual.sports.win', 'win', 'sports', false,  false, false, true,  'Virtual sports bet win'),
('horse.greyhound.win', 'win', 'sports', false,  false, false, true,  'Horse/Greyhound bet win'),
('casino.provider.bonus.win', 'win', 'casino', false,  false, false, true,  'Casino provider bonus win'),
-- BONUS / ADJUSTMENT
('bonus.transaction', 'bonus', NULL, true,  false, false, false, 'Generic bonus'),
('casino.bonus.transaction', 'bonus', 'casino', true,  false, false, false, 'Casino bonus'),
('casino.claimed.bonus', 'bonus', 'casino', true,  false, false, false, 'Claimed casino bonus'),
('casino.bonus.forfeit', 'bonus', 'casino', true,  false, false, false, 'Casino bonus forfeit'),
('discount.transaction', 'bonus', NULL, true,  false, false, false, 'Discount'),
('adjustment', 'adjustment', NULL, false, false, false, false, 'Manual adjustment'),
('casino.adjustment', 'adjustment', 'casino', false, false, false, false, 'Casino adjustment'),
-- PAYMENT / TRANSFER
('payment.provider.transaction', 'payment', 'payment', false, false, false, false, 'Payment provider transaction'),
('manual.payment.transaction', 'payment', 'payment', false, false, false, false, 'Manual payment'),
('manual.fund.transfer', 'payment', 'payment', false, false, false, false, 'Manual fund transfer'),
('casino.transfer.funds', 'payment', 'casino', false, false, false, false, 'Casino fund transfer'),
-- ROLLBACK TYPES
('sports.bet.wager.rollback', 'bet', 'sports', false,  false, true,  false, 'Sports bet rollback'),
('sports.win.rollback', 'win', 'sports', false,  false, true,  false, 'Sports bet win rollback'),
('free.sports.win.rollback', 'win', 'sports', true,  true,  true,  false, 'Free sports bet win rollback'),
('free.sports.wager.rollback', 'bet', 'sports', true,  true,  true,  false, 'Free bet wager rollback'),
('casino.bonus.transaction.rollback', 'bonus', 'casino', true,  false, true,  false, 'Casino bonus rollback'),
('bonus.transaction.rollback', 'bonus', NULL, true,  false, true,  false, 'Bonus rollback'),
('discount.transaction.rollback', 'bonus', NULL, true,  false, true,  false, 'Discount rollback'),
('casino.adjustment.rollback', 'adjustment', 'casino', false,  false, true,  false, 'Casino adjustment rollback');
