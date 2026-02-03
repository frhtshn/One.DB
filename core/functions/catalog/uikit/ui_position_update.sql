-- ================================================================
-- UI_POSITION_UPDATE: UI pozisyonu günceller
-- SuperAdmin kullanabilir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.ui_position_update(BIGINT, INT, VARCHAR, VARCHAR, BOOLEAN);

CREATE OR REPLACE FUNCTION catalog.ui_position_update(
    p_caller_id BIGINT,
    p_id INT,
    p_code VARCHAR(50) DEFAULT NULL,
    p_name VARCHAR(100) DEFAULT NULL,
    p_is_global BOOLEAN DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_code VARCHAR(50);
    v_existing_id INT;
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

    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.ui-position.id-required';
    END IF;

    IF NOT EXISTS(SELECT 1 FROM catalog.ui_positions up WHERE up.id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.ui-position.not-found';
    END IF;

    IF p_code IS NOT NULL THEN
        IF LENGTH(TRIM(p_code)) < 2 THEN
            RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.ui-position.code-invalid';
        END IF;

        v_code := LOWER(TRIM(p_code));

        SELECT up.id INTO v_existing_id
        FROM catalog.ui_positions up
        WHERE up.code = v_code AND up.id != p_id;

        IF v_existing_id IS NOT NULL THEN
            RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.ui-position.code-exists';
        END IF;
    END IF;

    IF p_name IS NOT NULL AND LENGTH(TRIM(p_name)) < 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.ui-position.name-invalid';
    END IF;

    UPDATE catalog.ui_positions SET
        code = COALESCE(LOWER(TRIM(p_code)), code),
        name = COALESCE(TRIM(p_name), name),
        is_global = COALESCE(p_is_global, is_global),
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.ui_position_update IS 'Updates a UI position. SuperAdmin only.';
