-- ================================================================
-- PAGE_CREATE: Yeni sayfa oluşturur
-- ================================================================

DROP FUNCTION IF EXISTS presentation.page_create CASCADE;
CREATE OR REPLACE FUNCTION presentation.page_create(
    p_menu_id BIGINT DEFAULT NULL,
    p_submenu_id BIGINT DEFAULT NULL,
    p_code TEXT DEFAULT NULL,
    p_route TEXT DEFAULT NULL,
    p_title_localization_key TEXT DEFAULT NULL,
    p_required_permission TEXT DEFAULT NULL,
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
        SELECT 1 FROM presentation.pages WHERE code = LOWER(TRIM(p_code))
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.page.code-exists';
    END IF;

    -- Ebeveyn kontrolü (menu_id XOR submenu_id)
    IF (p_menu_id IS NULL AND p_submenu_id IS NULL) OR (p_menu_id IS NOT NULL AND p_submenu_id IS NOT NULL) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0406', MESSAGE = 'error.page.parent-required';
    END IF;

    INSERT INTO presentation.pages (
        menu_id,
        submenu_id,
        code,
        route,
        title_localization_key,
        required_permission,
        is_active,
        created_at,
        updated_at
    ) VALUES (
        p_menu_id,
        p_submenu_id,
        LOWER(TRIM(p_code)),
        TRIM(p_route),
        p_title_localization_key,
        NULLIF(TRIM(p_required_permission), ''),
        p_is_active,
        NOW(),
        NOW()
    ) RETURNING id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION presentation.page_create IS 'Creates a new page with unique code validation and parent menu/submenu check.';
