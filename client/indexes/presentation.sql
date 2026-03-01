-- =============================================
-- Client Presentation Schema Indexes
-- =============================================

-- navigation
CREATE INDEX IF NOT EXISTS idx_navigation_menu_location ON presentation.navigation(menu_location);
CREATE INDEX IF NOT EXISTS idx_navigation_parent ON presentation.navigation(parent_id) WHERE parent_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_navigation_display_order ON presentation.navigation(menu_location, display_order);
CREATE INDEX IF NOT EXISTS idx_navigation_visible ON presentation.navigation(menu_location, is_visible) WHERE is_visible = TRUE;
CREATE INDEX IF NOT EXISTS idx_navigation_template_item ON presentation.navigation(template_item_id) WHERE template_item_id IS NOT NULL;

-- themes
CREATE UNIQUE INDEX IF NOT EXISTS idx_themes_active ON presentation.themes(is_active) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_themes_theme_id ON presentation.themes(theme_id);

-- layouts
CREATE INDEX IF NOT EXISTS idx_layouts_page ON presentation.layouts(page_id) WHERE page_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_layouts_name ON presentation.layouts(layout_name);
CREATE INDEX IF NOT EXISTS idx_layouts_active ON presentation.layouts(is_active) WHERE is_active = TRUE;
CREATE UNIQUE INDEX IF NOT EXISTS idx_layouts_page_name ON presentation.layouts(page_id, layout_name) WHERE is_active = TRUE;

-- =============================================
-- social_links
-- =============================================
CREATE INDEX IF NOT EXISTS idx_social_links_active_order ON presentation.social_links(is_active, display_order);

-- =============================================
-- announcement_bars
-- =============================================
CREATE INDEX IF NOT EXISTS idx_announcement_bars_active_schedule ON presentation.announcement_bars(is_active, starts_at, ends_at);
CREATE INDEX IF NOT EXISTS idx_announcement_bars_country_codes ON presentation.announcement_bars USING GIN(country_codes);
CREATE INDEX IF NOT EXISTS idx_announcement_bars_priority ON presentation.announcement_bars(priority DESC) WHERE is_active = TRUE;
