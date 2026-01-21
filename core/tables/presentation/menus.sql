DROP TABLE IF EXISTS presentation.menus CASCADE;

CREATE TABLE presentation.menus (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,                -- PLAYERS
    title_localization_key VARCHAR(150) NOT NULL,   -- bo.menu.players
    icon VARCHAR(50),
    order_index INT NOT NULL,
    required_permission VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true
);

