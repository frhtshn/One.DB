DROP TABLE IF EXISTS presentation.submenus CASCADE;

CREATE TABLE presentation.submenus (
    id BIGSERIAL PRIMARY KEY,
    menu_id BIGINT NOT NULL,
    code VARCHAR(50) NOT NULL,                        -- PLAYER_LIST
    title_localization_key VARCHAR(150) NOT NULL,
    route VARCHAR(200),
    order_index INT NOT NULL,
    required_permission VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    UNIQUE (menu_id, code)
);
