-- ============================================================================
-- PRESENTATION TRIGGERS
-- ============================================================================

-- Menu Groups
DROP TRIGGER IF EXISTS trigger_menu_groups_updated_at ON presentation.menu_groups;
CREATE TRIGGER trigger_menu_groups_updated_at
    BEFORE UPDATE ON presentation.menu_groups
    FOR EACH ROW EXECUTE FUNCTION core.update_updated_at_column();

-- Menus
DROP TRIGGER IF EXISTS trigger_menus_updated_at ON presentation.menus;
CREATE TRIGGER trigger_menus_updated_at
    BEFORE UPDATE ON presentation.menus
    FOR EACH ROW EXECUTE FUNCTION core.update_updated_at_column();

-- Submenus
DROP TRIGGER IF EXISTS trigger_submenus_updated_at ON presentation.submenus;
CREATE TRIGGER trigger_submenus_updated_at
    BEFORE UPDATE ON presentation.submenus
    FOR EACH ROW EXECUTE FUNCTION core.update_updated_at_column();

-- Pages
DROP TRIGGER IF EXISTS trigger_pages_updated_at ON presentation.pages;
CREATE TRIGGER trigger_pages_updated_at
    BEFORE UPDATE ON presentation.pages
    FOR EACH ROW EXECUTE FUNCTION core.update_updated_at_column();

-- Tabs
DROP TRIGGER IF EXISTS trigger_tabs_updated_at ON presentation.tabs;
CREATE TRIGGER trigger_tabs_updated_at
    BEFORE UPDATE ON presentation.tabs
    FOR EACH ROW EXECUTE FUNCTION core.update_updated_at_column();

-- Contexts
DROP TRIGGER IF EXISTS trigger_contexts_updated_at ON presentation.contexts;
CREATE TRIGGER trigger_contexts_updated_at
    BEFORE UPDATE ON presentation.contexts
    FOR EACH ROW EXECUTE FUNCTION core.update_updated_at_column();
