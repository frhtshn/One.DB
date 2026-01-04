DROP TABLE IF EXISTS transaction.transactions CASCADE;

CREATE TABLE transaction.transactions (
    id bigserial PRIMARY KEY,
    player_id bigint NOT NULL,
    wallet_id bigint NOT NULL,
    transaction_type varchar(30) NOT NULL,
    operation character(1) NOT NULL,
    amount numeric(18,8) NOT NULL,
    related_transaction_id bigint,
    idempotency_key varchar(100),
    source varchar(30) NOT NULL,
    metadata jsonb,
    created_at timestamp without time zone NOT NULL DEFAULT now()
);
