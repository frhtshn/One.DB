-- ================================================================
-- PERMISSION_TEMPLATE_FROM_USER: User'in effective set'inden template olustur
-- ================================================================
-- Effective = (Role Permissions + Granted Override) - Denied Override
-- Sadece context_id IS NULL override'lar dahil
-- IDOR: Company scope kontrolu
-- Returns: JSONB - yeni template bilgisi
-- ================================================================

DROP FUNCTION IF EXISTS security.permission_template_from_user(BIGINT, VARCHAR, VARCHAR, BIGINT, BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION security.permission_template_from_user(
    p_user_id BIGINT,
    p_code VARCHAR(100),
    p_name VARCHAR(150),
    p_company_id BIGINT,
    p_caller_id BIGINT,
    p_tenant_id BIGINT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_normalized_code VARCHAR(100);
    v_caller_company_id BIGINT;
    v_target_company_id BIGINT;
    v_has_platform_role BOOLEAN;
    v_new_id BIGINT;
    v_item_count INT;
BEGIN
    v_normalized_code := LOWER(TRIM(p_code));

    -- Code format kontrolu
    IF v_normalized_code IS NULL OR v_normalized_code = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.permission-template.code-required';
    END IF;

    IF v_normalized_code !~ '^[a-z][a-z0-9-]*$' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.permission-template.code-invalid-format';
    END IF;

    IF TRIM(p_name) IS NULL OR TRIM(p_name) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.permission-template.name-required';
    END IF;

    -- ========================================
    -- USER KONTROLU
    -- ========================================
    SELECT u.company_id FROM security.users u
    WHERE u.id = p_user_id AND u.status = 1
    INTO v_target_company_id;

    IF v_target_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
    END IF;

    -- ========================================
    -- IDOR KONTROLU
    -- ========================================
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
        IF v_target_company_id != v_caller_company_id THEN
            RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.user-scope-denied';
        END IF;

        IF p_company_id != v_caller_company_id THEN
            RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.company-scope-denied';
        END IF;
    END IF;

    -- ========================================
    -- DUPLICATE KONTROLU
    -- ========================================
    IF EXISTS(
        SELECT 1 FROM security.permission_templates
        WHERE code = v_normalized_code AND company_id = p_company_id AND deleted_at IS NULL
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.permission-template.code-exists';
    END IF;

    -- ========================================
    -- TEMPLATE OLUSTUR
    -- ========================================
    INSERT INTO security.permission_templates (code, name, description, company_id, is_active, created_by)
    VALUES (
        v_normalized_code,
        TRIM(p_name),
        'Auto-generated from user #' || p_user_id,
        p_company_id,
        TRUE,
        p_caller_id
    )
    RETURNING id INTO v_new_id;

    -- ========================================
    -- EFFECTIVE SET'TEN ITEMS OLUSTUR
    -- Effective = (Role Permissions + Granted Override) - Denied Override
    -- ========================================
    INSERT INTO security.permission_template_items (template_id, permission_id, added_by, added_at)
    SELECT v_new_id, perm_id, p_caller_id, NOW()
    FROM (
        -- Role permissions (global + tenant)
        SELECT DISTINCT rp.permission_id AS perm_id
        FROM security.role_permissions rp
        JOIN security.user_roles ur ON rp.role_id = ur.role_id
        JOIN security.roles r ON ur.role_id = r.id AND r.status = 1
        WHERE ur.user_id = p_user_id
          AND (ur.tenant_id IS NULL OR ur.tenant_id = p_tenant_id OR p_tenant_id IS NULL)

        UNION

        -- Granted overrides (context_id IS NULL)
        SELECT DISTINCT upo.permission_id
        FROM security.user_permission_overrides upo
        WHERE upo.user_id = p_user_id
          AND upo.is_granted = TRUE
          AND upo.context_id IS NULL
          AND (upo.tenant_id IS NULL OR upo.tenant_id = p_tenant_id OR p_tenant_id IS NULL)
          AND (upo.expires_at IS NULL OR upo.expires_at > NOW())
    ) all_perms
    WHERE perm_id NOT IN (
        -- Denied overrides cikarilir
        SELECT upo.permission_id
        FROM security.user_permission_overrides upo
        WHERE upo.user_id = p_user_id
          AND upo.is_granted = FALSE
          AND upo.context_id IS NULL
          AND (upo.tenant_id IS NULL OR upo.tenant_id = p_tenant_id OR p_tenant_id IS NULL)
          AND (upo.expires_at IS NULL OR upo.expires_at > NOW())
    )
    -- Sadece aktif permission'lar
    AND EXISTS (SELECT 1 FROM security.permissions p WHERE p.id = perm_id AND p.status = 1);

    GET DIAGNOSTICS v_item_count = ROW_COUNT;

    RETURN jsonb_build_object(
        'id', v_new_id,
        'code', v_normalized_code,
        'name', TRIM(p_name),
        'companyId', p_company_id,
        'itemCount', v_item_count,
        'sourceUserId', p_user_id
    );
END;
$$;

COMMENT ON FUNCTION security.permission_template_from_user IS
'Creates a template from user effective permission set. Formula: (Role + Granted) - Denied. IDOR protected.';
