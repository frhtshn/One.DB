-- Presentation Schema Indexes
-- FK indexes for optimal JOIN performance

-- menus.menu_group_id -> menu_groups.id
CREATE INDEX idx_menus_menu_group_id ON presentation.menus USING btree(menu_group_id);

-- submenus.menu_id -> menus.id
CREATE INDEX idx_submenus_menu_id ON presentation.submenus USING btree(menu_id);

-- pages.menu_id -> menus.id
CREATE INDEX idx_pages_menu_id ON presentation.pages USING btree(menu_id);

-- pages.submenu_id -> submenus.id
CREATE INDEX idx_pages_submenu_id ON presentation.pages USING btree(submenu_id);

-- tabs.page_id -> pages.id
CREATE INDEX idx_tabs_page_id ON presentation.tabs USING btree(page_id);

-- contexts.page_id -> pages.id
CREATE INDEX idx_contexts_page_id ON presentation.contexts USING btree(page_id);

-- Order indexes for sorting
CREATE INDEX idx_menu_groups_order ON presentation.menu_groups USING btree(order_index);
CREATE INDEX idx_menus_order ON presentation.menus USING btree(order_index);
CREATE INDEX idx_submenus_order ON presentation.submenus USING btree(menu_id, order_index);
CREATE INDEX idx_tabs_order ON presentation.tabs USING btree(page_id, order_index);
