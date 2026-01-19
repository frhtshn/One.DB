DROP TABLE IF EXISTS security.user_tenant_roles CASCADE;

CREATE TABLE security.user_tenant_roles (
    user_id BIGINT NOT NULL REFERENCES security.users(id) ON DELETE CASCADE,
    tenant_id BIGINT NOT NULL, -- core.tenants(id)
    role_id BIGINT NOT NULL REFERENCES security.roles(id),

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    PRIMARY KEY (user_id, tenant_id)
);
