INSERT INTO catalog.operation_types
(code, wallet_effect, affects_balance, affects_locked, description)
VALUES
('DEBIT',   -1, true,  false, 'Balance decrease'),
('CREDIT',   1, true,  false, 'Balance increase'),
('HOLD',     0, false, true,  'Lock funds'),
('RELEASE',  0, false, true,  'Release locked funds'),
('NOOP',     0, false, false, 'No wallet effect');
