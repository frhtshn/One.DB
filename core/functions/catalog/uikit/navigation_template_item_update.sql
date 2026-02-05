-- ================================================================
-- NAVIGATION_TEMPLATE_ITEM_UPDATE: Şablon öğesi günceller
-- ================================================================

DROP FUNCTION IF EXISTS catalog.navigation_template_item_update(
    BIGINT, VARCHAR, VARCHAR, JSONB, VARCHAR, VARCHAR, VARCHAR, VARCHAR, BIGINT, INT, BOOLEAN, BOOLEAN
);
DROP FUNCTION IF EXISTS catalog.navigation_template_item_update(
    BIGINT, VARCHAR, VARCHAR, TEXT, VARCHAR, VARCHAR, VARCHAR, VARCHAR, BIGINT, INT, BOOLEAN, BOOLEAN
);

CREATE OR REPLACE FUNCTION catalog.navigation_template_item_update(
    p_id BIGINT,
    p_menu_location VARCHAR(50) DEFAULT NULL,
    p_translation_key VARCHAR(100) DEFAULT NULL,
    p_default_label TEXT DEFAULT NULL,
    p_icon VARCHAR(50) DEFAULT NULL,
    p_target_type VARCHAR(20) DEFAULT NULL,
    p_target_url VARCHAR(255) DEFAULT NULL,
    p_target_action VARCHAR(50) DEFAULT NULL,
    p_parent_id BIGINT DEFAULT NULL,
    p_display_order INT DEFAULT NULL,
    p_is_locked BOOLEAN DEFAULT NULL,
    p_is_mandatory BOOLEAN DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_template_id INT;
BEGIN
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.navigation-template-item.id-required';
    END IF;

    SELECT nti.template_id INTO v_template_id
    FROM catalog.navigation_template_items nti
    WHERE nti.id = p_id;

    IF v_template_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.navigation-template-item.not-found';
    END IF;

    IF p_menu_location IS NOT NULL AND LENGTH(TRIM(p_menu_location)) < 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.navigation-template-item.menu-location-invalid';
    END IF;

    IF p_target_type IS NOT NULL AND p_target_type NOT IN ('INTERNAL', 'EXTERNAL', 'ACTION') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.navigation-template-item.target-type-invalid';
    END IF;

    -- Parent item kontrolü
    IF p_parent_id IS NOT NULL THEN
        IF NOT EXISTS(SELECT 1 FROM catalog.navigation_template_items nti WHERE nti.id = p_parent_id AND nti.template_id = v_template_id) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.navigation-template-item.parent-not-found';
        END IF;
        -- Kendi kendine parent olamaz
        IF p_parent_id = p_id THEN
            RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.navigation-template-item.self-parent';
        END IF;
    END IF;

    UPDATE catalog.navigation_template_items SET
        menu_location = COALESCE(TRIM(p_menu_location), menu_location),
        translation_key = COALESCE(TRIM(p_translation_key), translation_key),
        default_label = COALESCE(p_default_label::jsonb, default_label),
        icon = COALESCE(TRIM(p_icon), icon),
        target_type = COALESCE(p_target_type, target_type),
        target_url = COALESCE(TRIM(p_target_url), target_url),
        target_action = COALESCE(TRIM(p_target_action), target_action),
        parent_id = COALESCE(p_parent_id, parent_id),
        display_order = COALESCE(p_display_order, display_order),
        is_locked = COALESCE(p_is_locked, is_locked),
        is_mandatory = COALESCE(p_is_mandatory, is_mandatory),
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.navigation_template_item_update IS 'Updates a navigation template item.';
