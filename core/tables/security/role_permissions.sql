DROP TABLE IF EXISTS security.role_permissions CASCADE;

CREATE TABLE security.role_permissions (
    role_id BIGINT NOT NULL,
    permission_code VARCHAR(100) NOT NULL,
    PRIMARY KEY (role_id, permission_code)
);
