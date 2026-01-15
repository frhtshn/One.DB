DROP TABLE IF EXISTS transaction.transaction_workflows CASCADE;

CREATE TABLE transaction.transaction_workflows (
    id bigserial PRIMARY KEY,
    transaction_id bigint NOT NULL UNIQUE,
    workflow_type varchar(30) NOT NULL,
    status varchar(30) NOT NULL,
    reason varchar(255),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

