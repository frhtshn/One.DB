-- ================================================================
-- MENU_GROUP_CREATE: Yeni Menü Grubu Oluşturma
-- Kod benzersizliği kontrolü ile yeni bir menü grubu oluşturur.
-- ================================================================

DROP FUNCTION IF EXISTS presentation.menu_group_create CASCADE;

CREATE OR REPLACE FUNCTION presentation.menu_group_create(
    p_code TEXT,
    p_title TEXT,
    p_order INT,
    p_permission TEXT DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT TRUE
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_id BIGINT;
BEGIN
    -- Code benzersizlik kontrolü
    IF EXISTS (SELECT 1 FROM presentation.menu_groups WHERE code = UPPER(TRIM(p_code))) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.menu-group.code-exists';
    END IF;

    -- Menü grubu oluştur
    INSERT INTO presentation.menu_groups (
        code,
        title_localization_key,
        order_index,
        required_permission,
        is_active,
        created_at,
        updated_at
    )
    VALUES (
        UPPER(TRIM(p_code)),
        TRIM(p_title),
        p_order,
        NULLIF(TRIM(p_permission), ''),
        p_is_active,
        NOW(),
        NOW()
    )
    RETURNING presentation.menu_groups.id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION presentation.menu_group_create IS 'Creates a new menu group with unique code validation. Returns BIGINT.';
