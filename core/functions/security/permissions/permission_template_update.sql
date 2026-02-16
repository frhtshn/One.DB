-- ================================================================
-- PERMISSION_TEMPLATE_UPDATE: Template metadata guncelle + is_active toggle
-- Code DEGISTIRILEMEZ (immutable)
-- IDOR: Company scope kontrolu
-- Returns: VOID
-- ================================================================

DROP FUNCTION IF EXISTS security.permission_template_update(BIGINT, VARCHAR, VARCHAR, BOOLEAN, BIGINT);

CREATE OR REPLACE FUNCTION security.permission_template_update(
    p_id BIGINT,
    p_name VARCHAR(150) DEFAULT NULL,
    p_description VARCHAR(500) DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL,
    p_caller_id BIGINT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_template RECORD;
    v_caller_company_id BIGINT;
    v_has_platform_role BOOLEAN;
BEGIN
    -- Template var mi ve silinmemis mi?
    SELECT id, company_id, deleted_at
    INTO v_template
    FROM security.permission_templates
    WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.permission-template.not-found';
    END IF;

    IF v_template.deleted_at IS NOT NULL THEN
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
            -- Platform template'i (company_id IS NULL) sadece platform admin guncelleyebilir
            IF v_template.company_id IS NULL THEN
                RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.permission-denied';
            END IF;

            -- Company template: sadece kendi sirketi
            IF v_template.company_id != v_caller_company_id THEN
                RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.company-scope-denied';
            END IF;
        END IF;
    END IF;

    -- ========================================
    -- UPDATE
    -- ========================================
    UPDATE security.permission_templates
    SET
        name = COALESCE(NULLIF(TRIM(p_name), ''), name),
        description = CASE
            WHEN p_description IS NOT NULL THEN NULLIF(TRIM(p_description), '')
            ELSE description
        END,
        is_active = COALESCE(p_is_active, is_active),
        updated_by = p_caller_id,
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION security.permission_template_update IS 'Updates template metadata (name, description) and is_active toggle. Code is immutable. IDOR protected.';
