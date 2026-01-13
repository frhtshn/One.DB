DROP TABLE IF EXISTS catalog.operation_types CASCADE;

CREATE TABLE catalog.operation_types (
    code              varchar(30) PRIMARY KEY, -- DEBIT, CREDIT, HOLD, RELEASE
    wallet_effect     smallint NOT NULL,        -- -1, +1, 0
    affects_balance   boolean NOT NULL,
    affects_locked    boolean NOT NULL,
    description       text,
    is_active         boolean NOT NULL DEFAULT true
);

