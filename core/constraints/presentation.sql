-- Presentation Schema Foreign Key Constraints

-- menus -> menu_groups
ALTER TABLE presentation.menus
    ADD CONSTRAINT fk_menus_menu_group
    FOREIGN KEY (menu_group_id) REFERENCES presentation.menu_groups(id);

-- submenus -> menus
ALTER TABLE presentation.submenus
    ADD CONSTRAINT fk_submenus_menu
    FOREIGN KEY (menu_id) REFERENCES presentation.menus(id);

-- pages -> menus
ALTER TABLE presentation.pages
    ADD CONSTRAINT fk_pages_menu
    FOREIGN KEY (menu_id) REFERENCES presentation.menus(id);

-- pages -> submenus
ALTER TABLE presentation.pages
    ADD CONSTRAINT fk_pages_submenu
    FOREIGN KEY (submenu_id) REFERENCES presentation.submenus(id);

-- tabs -> pages
ALTER TABLE presentation.tabs
    ADD CONSTRAINT fk_tabs_page
    FOREIGN KEY (page_id) REFERENCES presentation.pages(id);

-- contexts -> pages
ALTER TABLE presentation.contexts
    ADD CONSTRAINT fk_contexts_page
    FOREIGN KEY (page_id) REFERENCES presentation.pages(id);
