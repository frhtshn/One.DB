DROP TABLE IF EXISTS presentation.pages CASCADE;

CREATE TABLE presentation.pages (
    id BIGSERIAL PRIMARY KEY,
    submenu_id BIGINT NOT NULL
        REFERENCES presentation.submenus(id) ON DELETE CASCADE,
    code VARCHAR(50) NOT NULL,                        -- PLAYER_DETAIL
    route VARCHAR(200) NOT NULL,                     -- /players/detail/:id
    title_localization_key VARCHAR(150) NOT NULL,
    required_permission VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    UNIQUE (submenu_id, code)
);

