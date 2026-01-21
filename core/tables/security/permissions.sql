DROP TABLE IF EXISTS security.permissions CASCADE;

CREATE TABLE security.permissions (
    code VARCHAR(100) PRIMARY KEY,      -- players.view
    description VARCHAR(255)
);


