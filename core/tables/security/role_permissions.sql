DROP TABLE IF EXISTS security.role_permissions CASCADE;

CREATE TABLE security.role_permissions (
    role_id BIGINT NOT NULL
        REFERENCES security.tenant_roles(id) ON DELETE CASCADE,
    permission_code VARCHAR(100) NOT NULL
        REFERENCES security.permissions(code),
    PRIMARY KEY (role_id, permission_code)
);

