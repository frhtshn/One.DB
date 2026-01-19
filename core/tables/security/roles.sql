DROP TABLE IF EXISTS security.roles CASCADE;

CREATE TABLE security.roles (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE, -- superadmin, editor, etc
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

