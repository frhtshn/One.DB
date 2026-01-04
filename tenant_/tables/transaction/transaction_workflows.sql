DROP TABLE IF EXISTS transaction.transaction_workflows CASCADE;

CREATE TABLE transaction.transaction_workflows (
    id bigserial PRIMARY KEY,
    transaction_id bigint NOT NULL,
    workflow_type varchar(30) NOT NULL,
    current_status varchar(30) NOT NULL,
    previous_status varchar(30),
    reason varchar(255),
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);
