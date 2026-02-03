-- ================================================================
-- NAVIGATION_TEMPLATE_CREATE: Yeni navigasyon şablonu oluşturur
-- SuperAdmin kullanabilir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.navigation_template_create(BIGINT, VARCHAR, VARCHAR, TEXT, BOOLEAN);

CREATE OR REPLACE FUNCTION catalog.navigation_template_create(
    p_caller_id BIGINT,
    p_code VARCHAR(50),
    p_name VARCHAR(100),
    p_description TEXT DEFAULT NULL,
    p_is_default BOOLEAN DEFAULT FALSE
)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_code VARCHAR(50);
    v_new_id INT;
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

    IF p_code IS NULL OR LENGTH(TRIM(p_code)) < 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.navigation-template.code-invalid';
    END IF;

    IF p_name IS NULL OR LENGTH(TRIM(p_name)) < 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.navigation-template.name-invalid';
    END IF;

    v_code := LOWER(TRIM(p_code));

    IF EXISTS(SELECT 1 FROM catalog.navigation_templates nt WHERE nt.code = v_code) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.navigation-template.code-exists';
    END IF;

    -- Yeni template default olacaksa diğerlerini kaldır
    IF p_is_default = TRUE THEN
        UPDATE catalog.navigation_templates SET is_default = FALSE WHERE is_default = TRUE;
    END IF;

    INSERT INTO catalog.navigation_templates (code, name, description, is_active, is_default, created_at, updated_at)
    VALUES (v_code, TRIM(p_name), TRIM(p_description), TRUE, COALESCE(p_is_default, FALSE), NOW(), NOW())
    RETURNING catalog.navigation_templates.id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION catalog.navigation_template_create IS 'Creates a new navigation template. SuperAdmin only.';
