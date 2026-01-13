DROP TABLE IF EXISTS catalog.transaction_types CASCADE;

CREATE TABLE core.transaction_types (
    code            varchar(50) PRIMARY KEY, -- IMMUTABLE
    category        varchar(30) NOT NULL,     -- BET, WIN, BONUS, PAYMENT, ADJUSTMENT
    product         varchar(30),              -- SPORTS, CASINO, POKER, PAYMENT
    is_bonus        boolean NOT NULL DEFAULT false,
    is_free         boolean NOT NULL DEFAULT false,
    is_rollback     boolean NOT NULL DEFAULT false,
    is_winning      boolean NOT NULL DEFAULT false,
    is_reportable   boolean NOT NULL DEFAULT true,
    description     text,
    is_active       boolean NOT NULL DEFAULT true,
    created_at      timestamptz NOT NULL DEFAULT now()
);
