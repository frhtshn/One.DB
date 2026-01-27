-- ================================================================
-- SUBMENU_CREATE: Yeni alt menü oluşturur
-- ================================================================

DROP FUNCTION IF EXISTS presentation.submenu_create CASCADE;
CREATE OR REPLACE FUNCTION presentation.submenu_create(
    p_menu_id BIGINT,
    p_code TEXT,
    p_title_localization_key TEXT,
    p_route TEXT DEFAULT NULL,
    p_order_index INT DEFAULT NULL,
    p_required_permission TEXT DEFAULT NULL
)
RETURNS TABLE(id BIGINT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_id BIGINT;
BEGIN
    -- Kod benzersizliği kontrolü (aynı menu_id altında)
    IF EXISTS (
        SELECT 1 FROM presentation.submenus WHERE code = UPPER(TRIM(p_code)) AND menu_id = p_menu_id AND is_active
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.submenu.code-exists';
    END IF;

    INSERT INTO presentation.submenus (
        menu_id,
        code,
        title_localization_key,
        route,
        order_index,
        required_permission,
        is_active,
        created_at,
        updated_at
    ) VALUES (
        p_menu_id,
        UPPER(TRIM(p_code)),
        p_title_localization_key,
        NULLIF(TRIM(p_route), ''),
        p_order_index,
        NULLIF(TRIM(p_required_permission), ''),
        TRUE,
        NOW(),
        NOW()
    ) RETURNING id INTO v_new_id;

    RETURN QUERY SELECT v_new_id;
END;
$$;

COMMENT ON FUNCTION presentation.submenu_create IS 'Creates a new submenu with unique code validation for the given menu.';
