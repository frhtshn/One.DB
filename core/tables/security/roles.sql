DROP TABLE IF EXISTS security.roles CASCADE;

CREATE TABLE security.roles (
    id BIGSERIAL PRIMARY KEY,

    company_id BIGINT NOT NULL
        REFERENCES core.companies(id),

    tenant_id BIGINT NULL
        REFERENCES core.tenants(id),
        -- NULL = tüm tenant’larda geçerli role

    code VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,

    is_system BOOLEAN NOT NULL DEFAULT false,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    UNIQUE (company_id, tenant_id, code)
);
