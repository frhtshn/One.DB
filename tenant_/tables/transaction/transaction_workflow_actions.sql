DROP TABLE IF EXISTS transaction.transaction_workflow_actions CASCADE;

CREATE TABLE transaction.transaction_workflow_actions (
    id bigserial PRIMARY KEY,
    workflow_id bigint NOT NULL,
    action varchar(30) NOT NULL,
    performed_by varchar(50),
    note varchar(255),
    created_at timestamp without time zone NOT NULL DEFAULT now()
);
