DROP TABLE IF EXISTS finance.operation_types CASCADE;

CREATE TABLE finance.operation_types (
    id                smallserial PRIMARY KEY,
    code              varchar(30) NOT NULL UNIQUE,
    wallet_effect     smallint NOT NULL,
    affects_balance   boolean NOT NULL,
    affects_locked    boolean NOT NULL
);
