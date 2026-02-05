INSERT INTO catalog.operation_types
(id, code, wallet_effect, affects_balance, affects_locked, description)
VALUES
(1, 'debit',   -1, true,  false, 'Balance decrease'),
(2, 'credit',   1, true,  false, 'Balance increase'),
(3, 'hold',     0, false, true,  'Lock funds'),
(4, 'release',  0, false, true,  'Release locked funds'),
(5, 'noop',     0, false, false, 'No wallet effect');