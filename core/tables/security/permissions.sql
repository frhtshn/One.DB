DROP TABLE IF EXISTS security.permissions CASCADE;

CREATE TABLE security.permissions (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(100) NOT NULL UNIQUE, -- player.phone.read
    description VARCHAR(255)
);
