DROP TABLE IF EXISTS presentation.menu_pages CASCADE;

CREATE TABLE presentation.menu_pages (
    menu_id BIGINT NOT NULL,
        --REFERENCES presentation.menus(id)
        --ON DELETE CASCADE,

    page_id BIGINT NOT NULL,
        --REFERENCES presentation.pages(id)
        --ON DELETE CASCADE,
    display_order INT,

    PRIMARY KEY (menu_id, page_id)
);
