-- Presentation Schema Indexes
-- FK indexes for optimal JOIN performance and Referral Integrity
-- (Checking parent existence or cascade delete)

-- menus.menu_group_id -> menu_groups.id
DROP INDEX IF EXISTS presentation.idx_menus_menu_group_id;
CREATE INDEX idx_menus_menu_group_id ON presentation.menus USING btree(menu_group_id);

-- submenus.menu_id -> menus.id
DROP INDEX IF EXISTS presentation.idx_submenus_menu_id;
CREATE INDEX idx_submenus_menu_id ON presentation.submenus USING btree(menu_id);

-- pages.menu_id -> menus.id
DROP INDEX IF EXISTS presentation.idx_pages_menu_id;
CREATE INDEX idx_pages_menu_id ON presentation.pages USING btree(menu_id);

-- pages.submenu_id -> submenus.id
DROP INDEX IF EXISTS presentation.idx_pages_submenu_id;
CREATE INDEX idx_pages_submenu_id ON presentation.pages USING btree(submenu_id);

-- tabs.page_id -> pages.id
DROP INDEX IF EXISTS presentation.idx_tabs_page_id;
CREATE INDEX idx_tabs_page_id ON presentation.tabs USING btree(page_id);

-- contexts.page_id -> pages.id
DROP INDEX IF EXISTS presentation.idx_contexts_page_id;
CREATE INDEX idx_contexts_page_id ON presentation.contexts USING btree(page_id);

-- Optimized Access Paths (Active Filter + Ordering)
-- Used by list functions (menu_group_list, menu_list, etc.)

-- menu_groups: List All Active Order By OrderIndex
DROP INDEX IF EXISTS presentation.idx_menu_groups_active_order;
CREATE INDEX idx_menu_groups_active_order ON presentation.menu_groups USING btree(is_active, order_index);

-- menus: Filter by Group AND Active Order By OrderIndex
DROP INDEX IF EXISTS presentation.idx_menus_group_active_order;
CREATE INDEX idx_menus_group_active_order ON presentation.menus USING btree(menu_group_id, is_active, order_index);

-- submenus: Filter by Menu AND Active Order By OrderIndex
DROP INDEX IF EXISTS presentation.idx_submenus_menu_active_order;
CREATE INDEX idx_submenus_menu_active_order ON presentation.submenus USING btree(menu_id, is_active, order_index);

-- pages: Filter by Menu/Submenu AND Active Order By OrderIndex
DROP INDEX IF EXISTS presentation.idx_pages_menu_active_order;
CREATE INDEX idx_pages_menu_active_order ON presentation.pages USING btree(menu_id, is_active, order_index);
DROP INDEX IF EXISTS presentation.idx_pages_submenu_active_order;
CREATE INDEX idx_pages_submenu_active_order ON presentation.pages USING btree(submenu_id, is_active, order_index);

-- tabs: Filter by Page AND Active Order By OrderIndex
DROP INDEX IF EXISTS presentation.idx_tabs_page_active_order;
CREATE INDEX idx_tabs_page_active_order ON presentation.tabs USING btree(page_id, is_active, order_index);

-- contexts: Filter by Page AND Active (Order is not primary, but lookup is)
-- Contexts are usually fetched by page_id and filtered by permissions, but active check is first.
DROP INDEX IF EXISTS presentation.idx_contexts_page_active;
CREATE INDEX idx_contexts_page_active ON presentation.contexts USING btree(page_id, is_active);
