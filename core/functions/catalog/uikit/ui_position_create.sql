-- ================================================================
-- UI_POSITION_CREATE: Yeni UI pozisyonu oluşturur
-- SuperAdmin kullanabilir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.ui_position_create(BIGINT, VARCHAR, VARCHAR, BOOLEAN);

CREATE OR REPLACE FUNCTION catalog.ui_position_create(
    p_caller_id BIGINT,
    p_code VARCHAR(50),
    p_name VARCHAR(100),
    p_is_global BOOLEAN DEFAULT FALSE
)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_code VARCHAR(50);
    v_new_id INT;
BEGIN
    -- SuperAdmin check
    PERFORM security.user_assert_superadmin(p_caller_id);

    IF p_code IS NULL OR LENGTH(TRIM(p_code)) < 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.ui-position.code-invalid';
    END IF;

    IF p_name IS NULL OR LENGTH(TRIM(p_name)) < 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.ui-position.name-invalid';
    END IF;

    v_code := LOWER(TRIM(p_code));

    IF EXISTS(SELECT 1 FROM catalog.ui_positions up WHERE up.code = v_code) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.ui-position.code-exists';
    END IF;

    INSERT INTO catalog.ui_positions (code, name, is_global, created_at, updated_at)
    VALUES (v_code, TRIM(p_name), COALESCE(p_is_global, FALSE), NOW(), NOW())
    RETURNING catalog.ui_positions.id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION catalog.ui_position_create IS 'Creates a new UI position. SuperAdmin only.';
