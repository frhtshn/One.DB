INSERT INTO catalog.transaction_types
(id, code, category, product, is_bonus, is_free, is_rollback, is_winning, is_reportable, description)
VALUES

-- BET TRANSACTIONS
(1,  'sports.bet', 'bet', 'sports', false, false, false, false, true, 'Sports bet wager'),
(2,  'free.sports.bet', 'bet', 'sports', true,  true,  false, false, true, 'Free sports bet'),
(3,  'casino.bet', 'bet', 'casino', false, false, false, false, true, 'Casino bet'),
(4,  'live.casino.bet', 'bet', 'casino', false, false, false, false, true, 'Live casino bet'),
(5,  'poker.bet', 'bet', 'poker', false, false, false, false, true, 'Poker bet'),
(6,  'virtual.sports.bet', 'bet', 'sports', false, false, false, false, true, 'Virtual sports bet'),
(7,  'horse.greyhound.bet', 'bet', 'sports', false, false, false, false, true, 'Horse/Greyhound bet'),
-- WIN TRANSACTIONS
(10, 'sports.bet.win', 'win', 'sports', false,  false, false, true,  true, 'Sports bet win'),
(11, 'free.sports.win', 'win', 'sports', true,  true,  false, true,  true, 'Free sports bet win'),
(12, 'casino.bet.win', 'win', 'casino', false,  false, false, true,  true, 'Casino bet win'),
(13, 'live.casino.win', 'win', 'casino', false,  false, false, true,  true, 'Live casino bet win'),
(14, 'poker.bet.win', 'win', 'poker', false,  false, false, true,  true, 'Poker bet win'),
(15, 'virtual.sports.win', 'win', 'sports', false,  false, false, true,  true, 'Virtual sports bet win'),
(16, 'horse.greyhound.win', 'win', 'sports', false,  false, false, true,  true, 'Horse/Greyhound bet win'),
(17, 'casino.provider.bonus.win', 'win', 'casino', false,  false, false, true,  true, 'Casino provider bonus win'),
-- BONUS / ADJUSTMENT
(20, 'bonus.transaction', 'bonus', NULL, true,  false, false, false, true, 'Generic bonus'),
(21, 'casino.bonus.transaction', 'bonus', 'casino', true,  false, false, false, true, 'Casino bonus'),
(22, 'casino.claimed.bonus', 'bonus', 'casino', true,  false, false, false, true, 'Claimed casino bonus'),
(23, 'casino.bonus.forfeit', 'bonus', 'casino', true,  false, false, false, true, 'Casino bonus forfeit'),
(24, 'discount.transaction', 'bonus', NULL, true,  false, false, false, true, 'Discount'),
(25, 'adjustment', 'adjustment', NULL, false, false, false, false, true, 'Manual adjustment'),
(26, 'casino.adjustment', 'adjustment', 'casino', false, false, false, false, true, 'Casino adjustment'),
-- PAYMENT / TRANSFER
(30, 'payment.provider.transaction', 'payment', 'payment', false, false, false, false, true, 'Payment provider transaction'),
(31, 'manual.payment.transaction', 'payment', 'payment', false, false, false, false, true, 'Manual payment'),
(32, 'manual.fund.transfer', 'payment', 'payment', false, false, false, false, true, 'Manual fund transfer'),
(33, 'casino.transfer.funds', 'payment', 'casino', false, false, false, false, true, 'Casino fund transfer'),
-- ROLLBACK TYPES
(40, 'sports.bet.wager.rollback', 'bet', 'sports', false,  false, true,  false, true, 'Sports bet rollback'),
(41, 'sports.win.rollback', 'win', 'sports', false,  false, true,  false, true, 'Sports bet win rollback'),
(42, 'free.sports.win.rollback', 'win', 'sports', true,  true,  true,  false, true, 'Free sports bet win rollback'),
(43, 'free.sports.wager.rollback', 'bet', 'sports', true,  true,  true,  false, true, 'Free bet wager rollback'),
(44, 'casino.bonus.transaction.rollback', 'bonus', 'casino', true,  false, true,  false, true, 'Casino bonus rollback'),
(45, 'bonus.transaction.rollback', 'bonus', NULL, true,  false, true,  false, true, 'Bonus rollback'),
(46, 'discount.transaction.rollback', 'bonus', NULL, true,  false, true,  false, true, 'Discount rollback'),
(47, 'casino.adjustment.rollback', 'adjustment', 'casino', false,  false, true,  false, true, 'Casino adjustment rollback');
