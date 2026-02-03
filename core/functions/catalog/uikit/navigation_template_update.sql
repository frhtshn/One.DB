-- ================================================================
-- NAVIGATION_TEMPLATE_UPDATE: Navigasyon şablonu günceller
-- SuperAdmin kullanabilir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.navigation_template_update(BIGINT, INT, VARCHAR, VARCHAR, TEXT, BOOLEAN, BOOLEAN);

CREATE OR REPLACE FUNCTION catalog.navigation_template_update(
    p_caller_id BIGINT,
    p_id INT,
    p_code VARCHAR(50) DEFAULT NULL,
    p_name VARCHAR(100) DEFAULT NULL,
    p_description TEXT DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL,
    p_is_default BOOLEAN DEFAULT NULL
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
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.navigation-template.id-required';
    END IF;

    IF NOT EXISTS(SELECT 1 FROM catalog.navigation_templates nt WHERE nt.id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.navigation-template.not-found';
    END IF;

    IF p_code IS NOT NULL THEN
        IF LENGTH(TRIM(p_code)) < 2 THEN
            RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.navigation-template.code-invalid';
        END IF;

        v_code := LOWER(TRIM(p_code));

        SELECT nt.id INTO v_existing_id
        FROM catalog.navigation_templates nt
        WHERE nt.code = v_code AND nt.id != p_id;

        IF v_existing_id IS NOT NULL THEN
            RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.navigation-template.code-exists';
        END IF;
    END IF;

    IF p_name IS NOT NULL AND LENGTH(TRIM(p_name)) < 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.navigation-template.name-invalid';
    END IF;

    -- Default yapılıyorsa diğerlerini kaldır
    IF p_is_default = TRUE THEN
        UPDATE catalog.navigation_templates SET is_default = FALSE WHERE is_default = TRUE AND id != p_id;
    END IF;

    UPDATE catalog.navigation_templates SET
        code = COALESCE(LOWER(TRIM(p_code)), code),
        name = COALESCE(TRIM(p_name), name),
        description = COALESCE(TRIM(p_description), description),
        is_active = COALESCE(p_is_active, is_active),
        is_default = COALESCE(p_is_default, is_default),
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.navigation_template_update IS 'Updates a navigation template. SuperAdmin only.';
