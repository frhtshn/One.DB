DROP TABLE IF EXISTS security.tenant_roles CASCADE;

CREATE TABLE security.tenant_roles (
    id BIGSERIAL PRIMARY KEY,
    tenant_id BIGINT NOT NULL,
    code VARCHAR(50) NOT NULL,              -- SUPERADMIN
    description VARCHAR(255),
    UNIQUE (tenant_id, code)
);


