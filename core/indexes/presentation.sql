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
CREATE INDEX IF NOT EXISTS idx_pages_submenu_id ON presentation.pages USING btree(submenu_id);

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

-- =========================================================================================
-- Theme & Navigation Indexes
-- =========================================================================================

-- tenant_themes
CREATE INDEX IF NOT EXISTS idx_tenant_themes_tenant ON presentation.tenant_themes USING btree(tenant_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_tenant_themes_active ON presentation.tenant_themes USING btree(tenant_id) WHERE is_active = true;

-- tenant_layouts
CREATE INDEX IF NOT EXISTS idx_tenant_layouts_tenant ON presentation.tenant_layouts USING btree(tenant_id);
CREATE INDEX IF NOT EXISTS idx_tenant_layouts_lookup ON presentation.tenant_layouts USING btree(tenant_id, layout_name);
CREATE UNIQUE INDEX IF NOT EXISTS idx_tenant_layouts_page ON presentation.tenant_layouts USING btree(tenant_id, page_id) WHERE page_id IS NOT NULL;

-- tenant_navigation
CREATE INDEX IF NOT EXISTS idx_tenant_navigation_tenant ON presentation.tenant_navigation USING btree(tenant_id);
CREATE INDEX IF NOT EXISTS idx_tenant_navigation_parent ON presentation.tenant_navigation USING btree(parent_id);
CREATE INDEX IF NOT EXISTS idx_tenant_navigation_ordering ON presentation.tenant_navigation USING btree(tenant_id, menu_location, display_order);
