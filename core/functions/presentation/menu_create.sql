-- ================================================================
-- MENU_CREATE: Yeni menü oluşturur
-- ================================================================

-- Tüm overload'ları CASCADE ile temizle
DROP FUNCTION IF EXISTS presentation.menu_create CASCADE;
CREATE OR REPLACE FUNCTION presentation.menu_create(
    p_menu_group_id BIGINT,
    p_code TEXT,
    p_title_localization_key TEXT,
    p_order_index INT,
    p_required_permission TEXT DEFAULT NULL,
    p_created_by BIGINT DEFAULT NULL,
    p_description TEXT DEFAULT NULL,
    p_icon TEXT DEFAULT NULL,
    p_is_system BOOLEAN DEFAULT FALSE,
    p_is_active BOOLEAN DEFAULT TRUE
)
RETURNS TABLE(id BIGINT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_id BIGINT;
BEGIN
    -- Kod benzersizliği kontrolü
    IF EXISTS (
        SELECT 1 FROM presentation.menus WHERE code = UPPER(TRIM(p_code)) AND menu_group_id = p_menu_group_id AND is_active
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.menu.code-exists';
    END IF;

    INSERT INTO presentation.menus (
        menu_group_id,
        code,
        title_localization_key,
        description,
        order_index,
        icon,
        required_permission,
        is_system,
        is_active,
        created_by,
        created_at,
        updated_at
    ) VALUES (
        p_menu_group_id,
        UPPER(TRIM(p_code)),
        p_title_localization_key,
        NULLIF(TRIM(p_description), ''),
        p_order_index,
        NULLIF(TRIM(p_icon), ''),
        NULLIF(TRIM(p_required_permission), ''),
        p_is_system,
        p_is_active,
        p_created_by,
        NOW(),
        NOW()
    ) RETURNING id INTO v_new_id;

    RETURN QUERY SELECT v_new_id;
END;
$$;

COMMENT ON FUNCTION presentation.menu_create IS 'Creates a new menu with unique code validation';
