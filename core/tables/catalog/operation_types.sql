DROP TABLE IF EXISTS catalog.operation_types CASCADE;

CREATE TABLE catalog.operation_types (
    id bigserial PRIMARY KEY,
    operation_code varchar(20) NOT NULL,
    description varchar(100),
    created_at timestamp without time zone NOT NULL DEFAULT now()
);
