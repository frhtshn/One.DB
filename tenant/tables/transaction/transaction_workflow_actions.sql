DROP TABLE IF EXISTS transaction.transaction_workflow_actions CASCADE;

CREATE TABLE transaction.transaction_workflow_actions (
    id bigserial PRIMARY KEY,
    workflow_id bigint NOT NULL,
    action varchar(30) NOT NULL,
    performed_by_id bigint,                 -- İşlemi yapan ID
    performed_by_type varchar(30) NOT NULL, -- BO_USER / SYSTEM / PLAYER
    note varchar(255),
    created_at timestamp without time zone NOT NULL DEFAULT now()
);
