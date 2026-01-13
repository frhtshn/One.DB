DROP TABLE IF EXISTS presentation.pages CASCADE;

CREATE TABLE presentation.pages (
    id BIGSERIAL PRIMARY KEY,

    code VARCHAR(50) NOT NULL UNIQUE,
    title VARCHAR(100) NOT NULL,

    route VARCHAR(200) NOT NULL,
    layout VARCHAR(50) NOT NULL DEFAULT 'default',

    is_active BOOLEAN NOT NULL DEFAULT true,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
