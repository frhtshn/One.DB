INSERT INTO catalog.operation_types
(code, wallet_effect, affects_balance, affects_locked, description)
VALUES
('debit',   -1, true,  false, 'Balance decrease'),
('credit',   1, true,  false, 'Balance increase'),
('hold',     0, false, true,  'Lock funds'),
('release',  0, false, true,  'Release locked funds'),
('noop',     0, false, false, 'No wallet effect');