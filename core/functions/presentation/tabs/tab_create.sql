-- ================================================================
-- TAB_CREATE: Yeni sekme oluşturur
-- ================================================================

DROP FUNCTION IF EXISTS presentation.tab_create CASCADE;
CREATE OR REPLACE FUNCTION presentation.tab_create(
    p_page_id BIGINT,
    p_code TEXT,
    p_title_localization_key TEXT,
    p_order_index INT,
    p_required_permission TEXT,
    p_is_active BOOLEAN DEFAULT TRUE
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_id BIGINT;
BEGIN
    -- Kod benzersizliği kontrolü (aynı page_id altında)
    IF EXISTS (
        SELECT 1 FROM presentation.tabs WHERE code = UPPER(TRIM(p_code)) AND page_id = p_page_id AND is_active
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.tab.code-exists';
    END IF;

    INSERT INTO presentation.tabs (
        page_id,
        code,
        title_localization_key,
        order_index,
        required_permission,
        is_active,
        created_at,
        updated_at
    ) VALUES (
        p_page_id,
        UPPER(TRIM(p_code)),
        p_title_localization_key,
        p_order_index,
        NULLIF(TRIM(p_required_permission), ''),
        p_is_active,
        NOW(),
        NOW()
    ) RETURNING id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION presentation.tab_create IS 'Creates a new tab with unique code validation for the given page.';
