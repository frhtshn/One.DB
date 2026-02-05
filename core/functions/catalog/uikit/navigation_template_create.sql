-- ================================================================
-- NAVIGATION_TEMPLATE_CREATE: Yeni navigasyon şablonu oluşturur
-- ================================================================

DROP FUNCTION IF EXISTS catalog.navigation_template_create(VARCHAR, VARCHAR, TEXT, BOOLEAN);

CREATE OR REPLACE FUNCTION catalog.navigation_template_create(
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

COMMENT ON FUNCTION catalog.navigation_template_create IS 'Creates a new navigation template.';
