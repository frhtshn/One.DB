DROP TABLE IF EXISTS transaction.transactions CASCADE;

CREATE TABLE transaction.transactions (
    id bigserial PRIMARY KEY,

    player_id bigint NOT NULL,
    wallet_id bigint NOT NULL,

    transaction_type_id smallint NOT NULL,
    operation_type_id   smallint NOT NULL,

    amount numeric(18,8) NOT NULL,
    balance_after numeric(18,8) NOT NULL,

    related_transaction_id bigint,
    idempotency_key varchar(100),

    source varchar(30) NOT NULL, -- GAME, PAYMENT, BONUS, ADMIN, MIGRATION

    metadata jsonb,

    created_at timestamptz NOT NULL DEFAULT now()
);
