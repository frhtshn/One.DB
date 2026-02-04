-- ================================================================
-- WIDGET_CREATE: Yeni widget oluşturur
-- SuperAdmin kullanabilir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.widget_create(BIGINT, VARCHAR, VARCHAR, VARCHAR, VARCHAR, TEXT, JSONB);
DROP FUNCTION IF EXISTS catalog.widget_create(BIGINT, VARCHAR, VARCHAR, VARCHAR, VARCHAR, TEXT, TEXT);

CREATE OR REPLACE FUNCTION catalog.widget_create(
    p_caller_id BIGINT,
    p_code VARCHAR(50),
    p_name VARCHAR(100),
    p_category VARCHAR(30),
    p_component_name VARCHAR(100),
    p_description TEXT DEFAULT NULL,
    p_default_props TEXT DEFAULT '{}'
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

    -- Kod kontrolü
    IF p_code IS NULL OR LENGTH(TRIM(p_code)) < 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.widget.code-invalid';
    END IF;

    -- İsim kontrolü
    IF p_name IS NULL OR LENGTH(TRIM(p_name)) < 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.widget.name-invalid';
    END IF;

    -- Kategori kontrolü
    IF p_category IS NULL OR p_category NOT IN ('CONTENT', 'GAME', 'ACCOUNT', 'NAVIGATION') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.widget.category-invalid';
    END IF;

    -- Component name kontrolü
    IF p_component_name IS NULL OR LENGTH(TRIM(p_component_name)) < 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.widget.component-name-invalid';
    END IF;

    v_code := LOWER(TRIM(p_code));

    -- Mevcut kod kontrolü
    IF EXISTS(SELECT 1 FROM catalog.widgets w WHERE w.code = v_code) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.widget.code-exists';
    END IF;

    -- Ekle
    INSERT INTO catalog.widgets (
        code, name, description, category, component_name,
        default_props, is_active, created_at, updated_at
    )
    VALUES (
        v_code, TRIM(p_name), TRIM(p_description), p_category, TRIM(p_component_name),
        COALESCE(p_default_props, '{}')::jsonb, TRUE, NOW(), NOW()
    )
    RETURNING catalog.widgets.id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION catalog.widget_create IS 'Creates a new widget. SuperAdmin only.';
