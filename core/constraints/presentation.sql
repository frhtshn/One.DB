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

-- contexts -> tabs (NULL = tab'sız düz sayfa context'i)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_contexts_tab') THEN
        ALTER TABLE presentation.contexts ADD CONSTRAINT fk_contexts_tab
            FOREIGN KEY (tab_id) REFERENCES presentation.tabs(id);
    END IF;
END $$;

-- Check Constraints
-- pages parent check (menu_id + submenu_id ayni anda dolu olamaz, ikisi NULL olabilir = standalone page)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_pages_parent') THEN
        ALTER TABLE presentation.pages ADD CONSTRAINT chk_pages_parent
            CHECK (menu_id IS NULL OR submenu_id IS NULL);
    END IF;
END $$;

-- contexts type check
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_contexts_type') THEN
        ALTER TABLE presentation.contexts ADD CONSTRAINT chk_contexts_type
            CHECK (context_type IN ('input', 'select', 'toggle', 'button', 'table', 'action', 'stat'));
    END IF;
END $$;

-- Unique Constraints: 1 submenu = 1 page, 1 menu = 1 page (submenu'suz)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'uq_pages_one_per_submenu') THEN
        CREATE UNIQUE INDEX uq_pages_one_per_submenu
            ON presentation.pages (submenu_id) WHERE submenu_id IS NOT NULL;
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'uq_pages_one_per_menu') THEN
        CREATE UNIQUE INDEX uq_pages_one_per_menu
            ON presentation.pages (menu_id) WHERE menu_id IS NOT NULL AND submenu_id IS NULL;
    END IF;
END $$;

-- Route kuralı: submenu_id varsa route NULL olmalı, yoksa route zorunlu
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_pages_route') THEN
        ALTER TABLE presentation.pages ADD CONSTRAINT chk_pages_route
            CHECK (
                (submenu_id IS NOT NULL AND route IS NULL)
                OR (submenu_id IS NULL AND route IS NOT NULL)
            );
    END IF;
END $$;

-- Theme & Navigation Constraints
-- Using DO block for idempotent execution

-- client_themes -> clients
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_client_themes_client') THEN
        ALTER TABLE presentation.client_themes ADD CONSTRAINT fk_client_themes_client
            FOREIGN KEY (client_id) REFERENCES core.clients(id);
    END IF;
END $$;

-- client_themes -> themes
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_client_themes_theme') THEN
        ALTER TABLE presentation.client_themes ADD CONSTRAINT fk_client_themes_theme
            FOREIGN KEY (theme_id) REFERENCES catalog.themes(id);
    END IF;
END $$;

-- client_layouts -> clients
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_client_layouts_client') THEN
        ALTER TABLE presentation.client_layouts ADD CONSTRAINT fk_client_layouts_client
            FOREIGN KEY (client_id) REFERENCES core.clients(id);
    END IF;
END $$;

-- client_navigation -> clients
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_client_navigation_client') THEN
        ALTER TABLE presentation.client_navigation ADD CONSTRAINT fk_client_navigation_client
            FOREIGN KEY (client_id) REFERENCES core.clients(id);
    END IF;
END $$;

-- client_navigation -> parent (Self Referencing)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_client_navigation_parent') THEN
        ALTER TABLE presentation.client_navigation ADD CONSTRAINT fk_client_navigation_parent
            FOREIGN KEY (parent_id) REFERENCES presentation.client_navigation(id) ON DELETE CASCADE;
    END IF;
END $$;

-- client_navigation -> template_item (Link to Master Data)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_client_navigation_template_item') THEN
        ALTER TABLE presentation.client_navigation ADD CONSTRAINT fk_client_navigation_template_item
            FOREIGN KEY (template_item_id) REFERENCES catalog.navigation_template_items(id) ON DELETE SET NULL;
    END IF;
END $$;

-- client_themes unique constraint (one config per theme per client)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_client_themes_client_theme') THEN
        ALTER TABLE presentation.client_themes ADD CONSTRAINT uq_client_themes_client_theme
            UNIQUE (client_id, theme_id);
    END IF;
END $$;

-- client_layouts unique constraint (one layout per name per client)
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_client_layouts_client_name') THEN
        ALTER TABLE presentation.client_layouts ADD CONSTRAINT uq_client_layouts_client_name
            UNIQUE (client_id, layout_name);
    END IF;
END $$;
