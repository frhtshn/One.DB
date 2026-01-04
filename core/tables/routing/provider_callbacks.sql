DROP TABLE IF EXISTS routing.provider_callbacks CASCADE;

CREATE TABLE routing.provider_callbacks (
    id bigserial PRIMARY KEY,
    provider_id bigint NOT NULL,
    callback_type varchar(50) NOT NULL,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp without time zone NOT NULL DEFAULT now()
);
