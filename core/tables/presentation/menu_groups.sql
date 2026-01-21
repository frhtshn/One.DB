DROP TABLE IF EXISTS presentation.menu_groups CASCADE;

CREATE TABLE presentation.menu_groups (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,                -- HOME, DOCUMENTS
    title_localization_key VARCHAR(150) NOT NULL,   -- bo.menu_group.home
    order_index INT NOT NULL,
    required_permission VARCHAR(100),               -- opsiyonel
    is_active BOOLEAN NOT NULL DEFAULT true
);
