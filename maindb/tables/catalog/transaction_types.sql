DROP TABLE IF EXISTS catalog.transaction_types CASCADE;

CREATE TABLE catalog.transaction_types (
    id bigserial PRIMARY KEY,
    transaction_code varchar(30) NOT NULL,
    operation_type_id bigint NOT NULL,
    description varchar(255),
    created_at timestamp without time zone NOT NULL DEFAULT now()
);
