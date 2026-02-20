-- =============================================
-- Tenant Presentation Schema Foreign Key Constraints
-- =============================================

-- navigation: Hiyerarşi (self-referencing)
ALTER TABLE presentation.navigation
    ADD CONSTRAINT fk_navigation_parent
    FOREIGN KEY (parent_id) REFERENCES presentation.navigation(id) ON DELETE CASCADE;

ALTER TABLE presentation.navigation
    ADD CONSTRAINT chk_navigation_target_type CHECK (target_type IN ('internal', 'external', 'action', 'route'));

ALTER TABLE presentation.navigation
    ADD CONSTRAINT chk_navigation_device_visibility CHECK (device_visibility IN ('all', 'mobile_only', 'desktop_only'));

-- themes: Tek aktif tema kontrolü
ALTER TABLE presentation.themes
    ADD CONSTRAINT chk_themes_config_jsonb CHECK (jsonb_typeof(config) = 'object');

-- layouts: Geçerli JSONB structure
ALTER TABLE presentation.layouts
    ADD CONSTRAINT chk_layouts_structure_jsonb CHECK (jsonb_typeof(structure) = 'array');
