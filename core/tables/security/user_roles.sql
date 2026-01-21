DROP TABLE IF EXISTS security.user_roles CASCADE;

CREATE TABLE security.tenant_user_roles (
    user_id BIGINT NOT NULL,
    tenant_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL
        REFERENCES security.tenant_roles(id),
    PRIMARY KEY (user_id, tenant_id, role_id)
);

