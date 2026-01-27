-- =============================================
-- 3. ROLE_CREATE: Yeni rol olustur
-- Returns: TABLE(id) - Permission pattern
-- =============================================

DROP FUNCTION IF EXISTS security.role_create(VARCHAR, VARCHAR, VARCHAR, BIGINT);

CREATE OR REPLACE FUNCTION security.role_create(
    p_code VARCHAR,
    p_name VARCHAR,
    p_description VARCHAR DEFAULT NULL,
    p_created_by BIGINT DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_code VARCHAR;
    v_existing_id BIGINT;
    v_existing_status SMALLINT;
    v_new_id BIGINT;
BEGIN
    v_code := LOWER(TRIM(p_code));

    -- Sistem rol ismi kullanilmasini engelle
    IF security.is_system_role(v_code) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.role.system-protected';
    END IF;

    -- Check existing
    SELECT r.id, r.status INTO v_existing_id, v_existing_status
    FROM security.roles r
    WHERE r.code = v_code;

    IF v_existing_id IS NOT NULL THEN
        IF v_existing_status = 0 THEN
            RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.role.create.code-deleted';
        ELSE
            RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.role.create.code-exists';
        END IF;
    END IF;

    -- Insert
    INSERT INTO security.roles (code, name, description, status, created_at, updated_at, created_by)
    VALUES (v_code, TRIM(p_name), NULLIF(TRIM(p_description), ''), 1, NOW(), NOW(), p_created_by)
    RETURNING security.roles.id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION security.role_create IS 'Creates a new role. Protects system roles.';
