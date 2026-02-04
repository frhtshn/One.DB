-- ================================================================
-- NAVIGATION_TEMPLATE_ITEM_CREATE: Yeni şablon öğesi oluşturur
-- SuperAdmin kullanabilir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.navigation_template_item_create(
    BIGINT, INT, VARCHAR, VARCHAR, JSONB, VARCHAR, VARCHAR, VARCHAR, VARCHAR, BIGINT, INT, BOOLEAN, BOOLEAN
);
DROP FUNCTION IF EXISTS catalog.navigation_template_item_create(
    BIGINT, INT, VARCHAR, VARCHAR, TEXT, VARCHAR, VARCHAR, VARCHAR, VARCHAR, BIGINT, INT, BOOLEAN, BOOLEAN
);

CREATE OR REPLACE FUNCTION catalog.navigation_template_item_create(
    p_caller_id BIGINT,
    p_template_id INT,
    p_menu_location VARCHAR(50),
    p_translation_key VARCHAR(100) DEFAULT NULL,
    p_default_label TEXT DEFAULT NULL,
    p_icon VARCHAR(50) DEFAULT NULL,
    p_target_type VARCHAR(20) DEFAULT 'INTERNAL',
    p_target_url VARCHAR(255) DEFAULT NULL,
    p_target_action VARCHAR(50) DEFAULT NULL,
    p_parent_id BIGINT DEFAULT NULL,
    p_display_order INT DEFAULT 0,
    p_is_locked BOOLEAN DEFAULT TRUE,
    p_is_mandatory BOOLEAN DEFAULT TRUE
)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_new_id BIGINT;
BEGIN
    -- SuperAdmin kontrolü
    IF NOT EXISTS(
        SELECT 1 FROM security.user_roles ur
        JOIN security.roles r ON ur.role_id = r.id
        WHERE ur.user_id = p_caller_id
          AND ur.tenant_id IS NULL
          AND r.code = 'superadmin'
          AND r.status = 1
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.unauthorized';
    END IF;

    IF p_template_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.navigation-template-item.template-required';
    END IF;

    IF NOT EXISTS(SELECT 1 FROM catalog.navigation_templates nt WHERE nt.id = p_template_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.navigation-template.not-found';
    END IF;

    IF p_menu_location IS NULL OR LENGTH(TRIM(p_menu_location)) < 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.navigation-template-item.menu-location-invalid';
    END IF;

    IF p_target_type IS NOT NULL AND p_target_type NOT IN ('INTERNAL', 'EXTERNAL', 'ACTION') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.navigation-template-item.target-type-invalid';
    END IF;

    -- Parent item kontrolü
    IF p_parent_id IS NOT NULL THEN
        IF NOT EXISTS(SELECT 1 FROM catalog.navigation_template_items nti WHERE nti.id = p_parent_id AND nti.template_id = p_template_id) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.navigation-template-item.parent-not-found';
        END IF;
    END IF;

    INSERT INTO catalog.navigation_template_items (
        template_id, menu_location, translation_key, default_label, icon,
        target_type, target_url, target_action, parent_id, display_order,
        is_locked, is_mandatory, created_at, updated_at
    )
    VALUES (
        p_template_id, TRIM(p_menu_location), TRIM(p_translation_key), p_default_label::jsonb, TRIM(p_icon),
        COALESCE(p_target_type, 'INTERNAL'), TRIM(p_target_url), TRIM(p_target_action), p_parent_id,
        COALESCE(p_display_order, 0), COALESCE(p_is_locked, TRUE), COALESCE(p_is_mandatory, TRUE),
        NOW(), NOW()
    )
    RETURNING catalog.navigation_template_items.id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION catalog.navigation_template_item_create IS 'Creates a navigation template item. SuperAdmin only.';
