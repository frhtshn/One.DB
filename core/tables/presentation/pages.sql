DROP TABLE IF EXISTS presentation.pages CASCADE;

CREATE TABLE presentation.pages (
    id BIGSERIAL PRIMARY KEY,

    menu_id BIGINT
        REFERENCES presentation.menus(id) ON DELETE CASCADE,

    submenu_id BIGINT
        REFERENCES presentation.submenus(id) ON DELETE CASCADE,

    code VARCHAR(50) NOT NULL,
    route VARCHAR(200) NOT NULL,
    title_localization_key VARCHAR(150) NOT NULL,
    required_permission VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,

    CHECK (
        (menu_id IS NOT NULL AND submenu_id IS NULL)
        OR
        (menu_id IS NULL AND submenu_id IS NOT NULL)
    )
);


