-- ================================================================
-- NAVIGATION_TEMPLATE_ITEM_LIST: Şablon öğelerini listeler
-- SuperAdmin erişebilir
-- Template ID zorunlu
-- ================================================================

DROP FUNCTION IF EXISTS catalog.navigation_template_item_list(BIGINT, INT, VARCHAR);

CREATE OR REPLACE FUNCTION catalog.navigation_template_item_list(
    p_caller_id BIGINT,
    p_template_id INT,
    p_menu_location VARCHAR(50) DEFAULT NULL
)
RETURNS TABLE(
    id BIGINT,
    template_id INT,
    menu_location VARCHAR(50),
    translation_key VARCHAR(100),
    default_label JSONB,
    icon VARCHAR(50),
    target_type VARCHAR(20),
    target_url VARCHAR(255),
    target_action VARCHAR(50),
    parent_id BIGINT,
    display_order INT,
    is_locked BOOLEAN,
    is_mandatory BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
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

    RETURN QUERY
    SELECT
        nti.id,
        nti.template_id,
        nti.menu_location,
        nti.translation_key,
        nti.default_label,
        nti.icon,
        nti.target_type,
        nti.target_url,
        nti.target_action,
        nti.parent_id,
        nti.display_order,
        nti.is_locked,
        nti.is_mandatory,
        nti.created_at,
        nti.updated_at
    FROM catalog.navigation_template_items nti
    WHERE nti.template_id = p_template_id
      AND (p_menu_location IS NULL OR nti.menu_location = p_menu_location)
    ORDER BY nti.menu_location, nti.display_order;
END;
$$;

COMMENT ON FUNCTION catalog.navigation_template_item_list IS 'Lists navigation template items. SuperAdmin only.';
