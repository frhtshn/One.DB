-- Presentation Schema Indexes
-- FK indexes for optimal JOIN performance and Referral Integrity
-- (Checking parent existence or cascade delete)

-- menus.menu_group_id -> menu_groups.id
CREATE INDEX IF NOT EXISTS idx_menus_menu_group_id ON presentation.menus USING btree(menu_group_id);

-- submenus.menu_id -> menus.id
CREATE INDEX IF NOT EXISTS idx_submenus_menu_id ON presentation.submenus USING btree(menu_id);

-- pages.menu_id -> menus.id
CREATE INDEX IF NOT EXISTS idx_pages_menu_id ON presentation.pages USING btree(menu_id);

-- pages.submenu_id -> submenus.id
-- pages.submenu_id -> submenus.id
CREATE INDEX IF NOT EXISTS idx_pages_submenu_id ON presentation.pages USING btree(submenu_id);

-- pages (unique lookup)
CREATE UNIQUE INDEX IF NOT EXISTS idx_pages_code ON presentation.pages USING btree(code);

-- tabs.page_id -> pages.id
CREATE INDEX IF NOT EXISTS idx_tabs_page_id ON presentation.tabs USING btree(page_id);

-- contexts.page_id -> pages.id
CREATE INDEX IF NOT EXISTS idx_contexts_page_id ON presentation.contexts USING btree(page_id);

-- Optimized Access Paths (Active Filter + Ordering)
-- Used by list functions (menu_group_list, menu_list, etc.)

-- menu_groups: List All Active Order By OrderIndex
CREATE INDEX IF NOT EXISTS idx_menu_groups_active_order ON presentation.menu_groups USING btree(is_active, order_index);

-- menus: Filter by Group AND Active Order By OrderIndex
CREATE INDEX IF NOT EXISTS idx_menus_group_active_order ON presentation.menus USING btree(menu_group_id, is_active, order_index);

-- submenus: Filter by Menu AND Active Order By OrderIndex
CREATE INDEX IF NOT EXISTS idx_submenus_menu_active_order ON presentation.submenus USING btree(menu_id, is_active, order_index);

-- pages: Filter by Menu/Submenu AND Active Order By OrderIndex
CREATE INDEX IF NOT EXISTS idx_pages_menu_active_order ON presentation.pages USING btree(menu_id, is_active, order_index);
CREATE INDEX IF NOT EXISTS idx_pages_submenu_active_order ON presentation.pages USING btree(submenu_id, is_active, order_index);

-- tabs: Filter by Page AND Active Order By OrderIndex
CREATE INDEX IF NOT EXISTS idx_tabs_page_active_order ON presentation.tabs USING btree(page_id, is_active, order_index);

-- contexts: Filter by Page AND Active (Order is not primary, but lookup is)
-- Contexts are usually fetched by page_id and filtered by permissions, but active check is first.
CREATE INDEX IF NOT EXISTS idx_contexts_page_active ON presentation.contexts USING btree(page_id, is_active);

-- contexts (unique lookup)
CREATE UNIQUE INDEX IF NOT EXISTS idx_contexts_page_code ON presentation.contexts USING btree(page_id, code);

-- =========================================================================================
-- Theme & Navigation Indexes
-- =========================================================================================

-- client_themes
CREATE INDEX IF NOT EXISTS idx_client_themes_client ON presentation.client_themes USING btree(client_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_client_themes_active ON presentation.client_themes USING btree(client_id) WHERE is_active = true;

-- client_layouts
CREATE INDEX IF NOT EXISTS idx_client_layouts_client ON presentation.client_layouts USING btree(client_id);
CREATE INDEX IF NOT EXISTS idx_client_layouts_lookup ON presentation.client_layouts USING btree(client_id, layout_name);
CREATE UNIQUE INDEX IF NOT EXISTS idx_client_layouts_page ON presentation.client_layouts USING btree(client_id, page_id) WHERE page_id IS NOT NULL;

-- client_navigation
CREATE INDEX IF NOT EXISTS idx_client_navigation_client ON presentation.client_navigation USING btree(client_id);
CREATE INDEX IF NOT EXISTS idx_client_navigation_parent ON presentation.client_navigation USING btree(parent_id);
CREATE INDEX IF NOT EXISTS idx_client_navigation_ordering ON presentation.client_navigation USING btree(client_id, menu_location, display_order);

-- client_themes (unique lookup)
CREATE UNIQUE INDEX IF NOT EXISTS idx_client_themes_client_theme ON presentation.client_themes USING btree(client_id, theme_id);

-- client_layouts (unique lookup)
CREATE UNIQUE INDEX IF NOT EXISTS idx_client_layouts_unique_layout ON presentation.client_layouts USING btree(client_id, page_id, layout_name);

-- =========================================================================================
-- GIN Indexes for JSONB Columns
-- =========================================================================================

-- presentation.client_themes (config)
CREATE INDEX IF NOT EXISTS idx_client_themes_config_gin ON presentation.client_themes USING gin(config);

-- presentation.client_navigation (custom_label)
CREATE INDEX IF NOT EXISTS idx_client_navigation_label_gin ON presentation.client_navigation USING gin(custom_label);

-- presentation.client_layouts (structure)
CREATE INDEX IF NOT EXISTS idx_client_layouts_structure_gin ON presentation.client_layouts USING gin(structure);
