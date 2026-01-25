DROP TABLE IF EXISTS security.secrets_tenant CASCADE;

CREATE TABLE security.secrets_tenant (
    id bigserial PRIMARY KEY,
    tenant_id bigint NOT NULL,
    secret_type varchar(50) NOT NULL,
    secret_value text NOT NULL,
    environment varchar(20) NOT NULL DEFAULT 'production',  -- production, staging, shadow
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    rotated_at timestamp without time zone
);
