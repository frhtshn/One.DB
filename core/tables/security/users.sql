DROP TABLE IF EXISTS security.users CASCADE;

CREATE TABLE security.users (
    id BIGSERIAL PRIMARY KEY,

    company_id BIGINT NOT NULL,
        --REFERENCES core.companies(id),

    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,        

    email VARCHAR(255) NOT NULL,
    username VARCHAR(50) NOT NULL,

    password VARCHAR(255) NOT NULL,

    status SMALLINT NOT NULL DEFAULT 1,
    is_locked BOOLEAN NOT NULL DEFAULT false,

    failed_login_count INT NOT NULL DEFAULT 0,
    last_login_at TIMESTAMPTZ,

    two_factor_enabled BOOLEAN NOT NULL DEFAULT false,
    two_factor_secret VARCHAR(255),

    language CHAR(2),

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    UNIQUE (company_id, email),
    UNIQUE (company_id, username)
);
