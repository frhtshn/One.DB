DROP TABLE IF EXISTS presentation.menus CASCADE;

CREATE TABLE presentation.menus (
    id BIGSERIAL PRIMARY KEY,
    menu_group_id BIGINT,
    code VARCHAR(50) NOT NULL UNIQUE,
    title_localization_key VARCHAR(150) NOT NULL,
    icon VARCHAR(50),
    order_index INT NOT NULL,
    required_permission VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true
);
