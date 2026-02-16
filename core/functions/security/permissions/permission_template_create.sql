-- ================================================================
-- PERMISSION_TEMPLATE_CREATE: Yeni permission template olustur
-- IDOR: Company scope kontrolu — caller kendi sirketine template olusturabilir
-- Platform admin (p_caller_id NULL veya platform role): company_id=NULL template olusturabilir
-- Returns: JSONB - olusturulan template bilgisi
-- ================================================================

DROP FUNCTION IF EXISTS security.permission_template_create(VARCHAR, VARCHAR, VARCHAR, BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION security.permission_template_create(
    p_code VARCHAR(100),
    p_name VARCHAR(150),
    p_description VARCHAR(500) DEFAULT NULL,
    p_company_id BIGINT DEFAULT NULL,
    p_caller_id BIGINT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_normalized_code VARCHAR(100);
    v_caller_company_id BIGINT;
    v_has_platform_role BOOLEAN;
    v_new_id BIGINT;
BEGIN
    -- Code'u normalize et
    v_normalized_code := LOWER(TRIM(p_code));

    -- Bos code kontrolu
    IF v_normalized_code IS NULL OR v_normalized_code = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.permission-template.code-required';
    END IF;

    -- Code format kontrolu (regex constraint'ten once yakala, daha iyi hata mesaji)
    IF v_normalized_code !~ '^[a-z][a-z0-9-]*$' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.permission-template.code-invalid-format';
    END IF;

    -- Name kontrolu
    IF TRIM(p_name) IS NULL OR TRIM(p_name) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.permission-template.name-required';
    END IF;

    -- ========================================
    -- IDOR KONTROLU
    -- ========================================
    IF p_caller_id IS NOT NULL THEN
        -- Caller bilgisi
        SELECT u.company_id FROM security.users u
        WHERE u.id = p_caller_id AND u.status = 1
        INTO v_caller_company_id;

        IF v_caller_company_id IS NULL THEN
            RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.unauthorized';
        END IF;

        -- Platform admin kontrolu
        SELECT EXISTS(
            SELECT 1 FROM security.user_roles ur
            JOIN security.roles r ON ur.role_id = r.id
            WHERE ur.user_id = p_caller_id AND ur.tenant_id IS NULL AND r.is_platform_role = TRUE
        ) INTO v_has_platform_role;

        IF NOT v_has_platform_role THEN
            -- Platform admin degilse sadece kendi sirketine template olusturabilir
            IF p_company_id IS NULL THEN
                RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.permission-denied';
            END IF;

            IF p_company_id != v_caller_company_id THEN
                RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.company-scope-denied';
            END IF;
        END IF;
    END IF;

    -- ========================================
    -- DUPLICATE KONTROLU
    -- ========================================
    IF p_company_id IS NULL THEN
        -- Platform-level: ayni code var mi?
        IF EXISTS(
            SELECT 1 FROM security.permission_templates
            WHERE code = v_normalized_code AND company_id IS NULL AND deleted_at IS NULL
        ) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.permission-template.code-exists';
        END IF;
    ELSE
        -- Company-scoped: ayni company + code var mi?
        IF EXISTS(
            SELECT 1 FROM security.permission_templates
            WHERE code = v_normalized_code AND company_id = p_company_id AND deleted_at IS NULL
        ) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.permission-template.code-exists';
        END IF;
    END IF;

    -- ========================================
    -- INSERT
    -- ========================================
    INSERT INTO security.permission_templates (code, name, description, company_id, created_by)
    VALUES (v_normalized_code, TRIM(p_name), NULLIF(TRIM(p_description), ''), p_company_id, COALESCE(p_caller_id, 0))
    RETURNING id INTO v_new_id;

    RETURN jsonb_build_object(
        'id', v_new_id,
        'code', v_normalized_code,
        'name', TRIM(p_name),
        'companyId', p_company_id
    );
END;
$$;

COMMENT ON FUNCTION security.permission_template_create IS 'Creates a new permission template. IDOR protected: non-platform users can only create for their own company.';
