DROP TABLE IF EXISTS security.role_permissions CASCADE;

CREATE TABLE security.role_permissions (
    role_id BIGINT NOT NULL REFERENCES security.roles(id),
    permission_id BIGINT NOT NULL REFERENCES security.permissions(id),
    PRIMARY KEY (role_id, permission_id)
);
