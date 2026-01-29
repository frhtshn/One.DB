-- Presentation Schema Foreign Key Constraints
-- Using IF NOT EXISTS pattern for idempotent deploys

-- menus -> menu_groups
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_menus_menu_group') THEN
        ALTER TABLE presentation.menus ADD CONSTRAINT fk_menus_menu_group
            FOREIGN KEY (menu_group_id) REFERENCES presentation.menu_groups(id);
    END IF;
END $$;

-- submenus -> menus
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_submenus_menu') THEN
        ALTER TABLE presentation.submenus ADD CONSTRAINT fk_submenus_menu
            FOREIGN KEY (menu_id) REFERENCES presentation.menus(id);
    END IF;
END $$;

-- pages -> menus
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_pages_menu') THEN
        ALTER TABLE presentation.pages ADD CONSTRAINT fk_pages_menu
            FOREIGN KEY (menu_id) REFERENCES presentation.menus(id);
    END IF;
END $$;

-- pages -> submenus
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_pages_submenu') THEN
        ALTER TABLE presentation.pages ADD CONSTRAINT fk_pages_submenu
            FOREIGN KEY (submenu_id) REFERENCES presentation.submenus(id);
    END IF;
END $$;

-- tabs -> pages
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tabs_page') THEN
        ALTER TABLE presentation.tabs ADD CONSTRAINT fk_tabs_page
            FOREIGN KEY (page_id) REFERENCES presentation.pages(id);
    END IF;
END $$;

-- contexts -> pages
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_contexts_page') THEN
        ALTER TABLE presentation.contexts ADD CONSTRAINT fk_contexts_page
            FOREIGN KEY (page_id) REFERENCES presentation.pages(id);
    END IF;
END $$;



-- Check Constraints
-- pages parent check
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_pages_parent') THEN
        ALTER TABLE presentation.pages ADD CONSTRAINT chk_pages_parent
            CHECK ((menu_id IS NOT NULL AND submenu_id IS NULL) OR (menu_id IS NULL AND submenu_id IS NOT NULL));
    END IF;
END $$;

-- contexts type check
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_contexts_type') THEN
        ALTER TABLE presentation.contexts ADD CONSTRAINT chk_contexts_type
            CHECK (context_type IN ('field', 'action', 'section', 'button'));
    END IF;
END $$;

-- Theme & Navigation Constraints
-- Using DO block for idempotent execution

-- tenant_themes -> tenants
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tenant_themes_tenant') THEN
        ALTER TABLE presentation.tenant_themes ADD CONSTRAINT fk_tenant_themes_tenant
            FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);
    END IF;
END $$;

-- tenant_themes -> themes
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tenant_themes_theme') THEN
        ALTER TABLE presentation.tenant_themes ADD CONSTRAINT fk_tenant_themes_theme
            FOREIGN KEY (theme_id) REFERENCES catalog.themes(id);
    END IF;
END $$;

-- tenant_layouts -> tenants
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tenant_layouts_tenant') THEN
        ALTER TABLE presentation.tenant_layouts ADD CONSTRAINT fk_tenant_layouts_tenant
            FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);
    END IF;
END $$;

-- tenant_navigation -> tenants
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tenant_navigation_tenant') THEN
        ALTER TABLE presentation.tenant_navigation ADD CONSTRAINT fk_tenant_navigation_tenant
            FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);
    END IF;
END $$;

-- tenant_navigation -> parent (Self Referencing)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tenant_navigation_parent') THEN
        ALTER TABLE presentation.tenant_navigation ADD CONSTRAINT fk_tenant_navigation_parent
            FOREIGN KEY (parent_id) REFERENCES presentation.tenant_navigation(id) ON DELETE CASCADE;
    END IF;
END $$;

-- tenant_navigation -> template_item (Link to Master Data)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tenant_navigation_template_item') THEN
        ALTER TABLE presentation.tenant_navigation ADD CONSTRAINT fk_tenant_navigation_template_item
            FOREIGN KEY (template_item_id) REFERENCES catalog.navigation_template_items(id) ON DELETE SET NULL;
    END IF;
END $$;
