-- ================================================================
-- MENU_GROUP_CREATE: Yeni menü grubu oluştur
-- ================================================================

-- Tüm overload'ları CASCADE ile temizle
DROP FUNCTION IF EXISTS presentation.menu_group_create CASCADE;

CREATE OR REPLACE FUNCTION presentation.menu_group_create(
    p_code TEXT,
    p_title TEXT,
    p_order INT,
    p_is_active BOOLEAN DEFAULT TRUE
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_id BIGINT;
BEGIN
    -- Code benzersizlik kontrolü
    IF EXISTS (SELECT 1 FROM presentation.menu_groups WHERE code = LOWER(TRIM(p_code))) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.menu-group.code-exists';
    END IF;

    -- Menü grubu oluştur
    INSERT INTO presentation.menu_groups (
        code,
        title_localization_key,
        order_index,

        is_active,
        created_at,
        updated_at
    )
    VALUES (
        LOWER(TRIM(p_code)),
        TRIM(p_title),
        p_order,

        p_is_active,
        NOW(),
        NOW()
    )
    RETURNING presentation.menu_groups.id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION presentation.menu_group_create IS 'Creates a new menu group with unique code validation';
