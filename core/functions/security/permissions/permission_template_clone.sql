-- ================================================================
-- PERMISSION_TEMPLATE_CLONE: Template kopyala (metadata + items)
-- Yeni code/name ile yeni template olusturur, kaynak items'i kopyalar
-- IDOR: Company scope kontrolu
-- Returns: JSONB - yeni template bilgisi
-- ================================================================

DROP FUNCTION IF EXISTS security.permission_template_clone(BIGINT, VARCHAR, VARCHAR, BIGINT);

CREATE OR REPLACE FUNCTION security.permission_template_clone(
    p_source_id BIGINT,
    p_new_code VARCHAR(100),
    p_new_name VARCHAR(150),
    p_caller_id BIGINT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_source RECORD;
    v_caller_company_id BIGINT;
    v_has_platform_role BOOLEAN;
    v_new_id BIGINT;
    v_item_count INT;
    v_normalized_code VARCHAR(100);
BEGIN
    v_normalized_code := LOWER(TRIM(p_new_code));

    -- Code format kontrolu
    IF v_normalized_code IS NULL OR v_normalized_code = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.permission-template.code-required';
    END IF;

    IF v_normalized_code !~ '^[a-z][a-z0-9-]*$' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.permission-template.code-invalid-format';
    END IF;

    IF TRIM(p_new_name) IS NULL OR TRIM(p_new_name) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.permission-template.name-required';
    END IF;

    -- Kaynak template
    SELECT id, code, name, description, company_id, deleted_at
    INTO v_source
    FROM security.permission_templates
    WHERE id = p_source_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.permission-template.not-found';
    END IF;

    IF v_source.deleted_at IS NOT NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.permission-template.deleted';
    END IF;

    -- ========================================
    -- IDOR KONTROLU
    -- ========================================
    IF p_caller_id IS NOT NULL THEN
        SELECT u.company_id FROM security.users u
        WHERE u.id = p_caller_id AND u.status = 1
        INTO v_caller_company_id;

        IF v_caller_company_id IS NULL THEN
            RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.unauthorized';
        END IF;

        SELECT EXISTS(
            SELECT 1 FROM security.user_roles ur
            JOIN security.roles r ON ur.role_id = r.id
            WHERE ur.user_id = p_caller_id AND ur.tenant_id IS NULL AND r.is_platform_role = TRUE
        ) INTO v_has_platform_role;

        IF NOT v_has_platform_role THEN
            IF v_source.company_id IS NULL THEN
                RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.permission-denied';
            END IF;

            IF v_source.company_id != v_caller_company_id THEN
                RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.company-scope-denied';
            END IF;
        END IF;
    END IF;

    -- ========================================
    -- DUPLICATE KONTROLU (yeni code)
    -- ========================================
    IF v_source.company_id IS NULL THEN
        IF EXISTS(
            SELECT 1 FROM security.permission_templates
            WHERE code = v_normalized_code AND company_id IS NULL AND deleted_at IS NULL
        ) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.permission-template.code-exists';
        END IF;
    ELSE
        IF EXISTS(
            SELECT 1 FROM security.permission_templates
            WHERE code = v_normalized_code AND company_id = v_source.company_id AND deleted_at IS NULL
        ) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.permission-template.code-exists';
        END IF;
    END IF;

    -- ========================================
    -- CLONE: Yeni template olustur
    -- ========================================
    INSERT INTO security.permission_templates (code, name, description, company_id, is_active, created_by)
    VALUES (v_normalized_code, TRIM(p_new_name), v_source.description, v_source.company_id, TRUE, COALESCE(p_caller_id, 0))
    RETURNING id INTO v_new_id;

    -- Items'i kopyala
    INSERT INTO security.permission_template_items (template_id, permission_id, added_by, added_at)
    SELECT v_new_id, pti.permission_id, COALESCE(p_caller_id, 0), NOW()
    FROM security.permission_template_items pti
    WHERE pti.template_id = p_source_id;

    GET DIAGNOSTICS v_item_count = ROW_COUNT;

    RETURN jsonb_build_object(
        'id', v_new_id,
        'code', v_normalized_code,
        'name', TRIM(p_new_name),
        'companyId', v_source.company_id,
        'itemCount', v_item_count,
        'sourceId', p_source_id
    );
END;
$$;

COMMENT ON FUNCTION security.permission_template_clone IS 'Clones a template with new code/name. Copies all permission items. IDOR protected.';
