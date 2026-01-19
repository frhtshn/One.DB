DROP TABLE IF EXISTS wallet.wallet_snapshots CASCADE;

CREATE TABLE wallet.wallet_snapshots (
    wallet_id bigint PRIMARY KEY,
    balance numeric(18,8) NOT NULL,
    last_transaction_id bigint NOT NULL,
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);
