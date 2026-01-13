DROP TABLE IF EXISTS presentation.menus CASCADE;

CREATE TABLE presentation.menus (
    id BIGSERIAL PRIMARY KEY,

    sidebar_group VARCHAR(50) NOT NULL,        -- AI Apps, Pages, Finance...
    code VARCHAR(50) NOT NULL UNIQUE,

    title VARCHAR(100) NOT NULL,
    icon VARCHAR(50),
    route VARCHAR(200),                         -- varsa direkt page
    display_order INT NOT NULL,

    is_clickable BOOLEAN NOT NULL DEFAULT true,
    is_active BOOLEAN NOT NULL DEFAULT true,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
