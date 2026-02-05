-- ================================================================
-- NAVIGATION_TEMPLATE_ITEM_GET: Tekil şablon öğesi getirir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.navigation_template_item_get(BIGINT);

CREATE OR REPLACE FUNCTION catalog.navigation_template_item_get(
    p_id BIGINT
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
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.navigation-template-item.id-required';
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
    WHERE nti.id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.navigation-template-item.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION catalog.navigation_template_item_get IS 'Gets a single navigation template item.';
