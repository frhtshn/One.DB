-- ================================================================
-- MENU_CREATE: Yeni Menü Oluşturma
-- Kod benzersizliği kontrolü ile yeni bir menü oluşturur.
-- ================================================================

DROP FUNCTION IF EXISTS presentation.menu_create CASCADE;

CREATE OR REPLACE FUNCTION presentation.menu_create(
    p_menu_group_id BIGINT,
    p_code TEXT,
    p_title_localization_key TEXT,
    p_order_index INT,
    p_required_permission TEXT DEFAULT NULL,
    p_icon TEXT DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT TRUE
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_id BIGINT;
BEGIN
    -- Kod benzersizliği kontrolü
    IF EXISTS (
        SELECT 1 FROM presentation.menus WHERE code = LOWER(TRIM(p_code)) AND menu_group_id = p_menu_group_id AND is_active
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.menu.code-exists';
    END IF;

    INSERT INTO presentation.menus (
        menu_group_id,
        code,
        title_localization_key,
        order_index,
        icon,
        required_permission,
        is_active,
        created_at,
        updated_at
    ) VALUES (
        p_menu_group_id,
        LOWER(TRIM(p_code)),
        p_title_localization_key,
        p_order_index,
        NULLIF(TRIM(p_icon), ''),
        NULLIF(TRIM(p_required_permission), ''),
        p_is_active,
        NOW(),
        NOW()
    ) RETURNING id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION presentation.menu_create IS 'Creates a new menu with unique code validation';
