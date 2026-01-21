DROP TABLE IF EXISTS security.user_roles CASCADE;

CREATE TABLE security.user_roles (
    user_id BIGINT NOT NULL,
    tenant_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    PRIMARY KEY (user_id, tenant_id, role_id)
);
