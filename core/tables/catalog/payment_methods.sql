DROP TABLE IF EXISTS catalog.payment_methods CASCADE;

CREATE TABLE catalog.payment_methods (
    id bigserial PRIMARY KEY,
    provider_id bigint NOT NULL,
    payment_method_code varchar(100) NOT NULL,
    payment_method_name varchar(255) NOT NULL,
    payment_type varchar(50),
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);
