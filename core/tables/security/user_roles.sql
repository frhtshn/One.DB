DROP TABLE IF EXISTS security.user_roles CASCADE;

CREATE TABLE security.user_roles (
    user_id BIGINT NOT NULL
        REFERENCES security.users(id)
        ON DELETE CASCADE,

    role_id BIGINT NOT NULL
        REFERENCES security.roles(id)
        ON DELETE CASCADE,

    PRIMARY KEY (user_id, role_id)
);
