DROP TABLE IF EXISTS finance.transaction_types CASCADE;

CREATE TABLE finance.transaction_types (
    id              smallserial PRIMARY KEY,
    code            varchar(50) NOT NULL UNIQUE,
    category        varchar(30) NOT NULL,
    product         varchar(30),
    is_bonus        boolean NOT NULL,
    is_free         boolean NOT NULL,
    is_rollback     boolean NOT NULL,
    is_winning      boolean NOT NULL,
    is_reportable   boolean NOT NULL,
    is_active       boolean NOT NULL DEFAULT true
);
