-- ================================================================
-- PERMISSION_TEMPLATE_GET: Template detayi (items + assignments dahil)
-- IDOR: Company scope kontrolu
-- Returns: JSONB - template + items + assignments listesi
-- ================================================================

DROP FUNCTION IF EXISTS security.permission_template_get(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION security.permission_template_get(
    p_id BIGINT,
    p_caller_id BIGINT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_template RECORD;
    v_caller_company_id BIGINT;
    v_has_platform_role BOOLEAN;
    v_items JSONB;
    v_assignments JSONB;
BEGIN
    -- Template var mi?
    SELECT id, code, name, description, company_id, is_active,
           created_by, created_at, updated_by, updated_at, deleted_at
    INTO v_template
    FROM security.permission_templates
    WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.permission-template.not-found';
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
            -- Platform template'lere (company_id IS NULL) erisim yok
            -- Company template: sadece kendi sirketi
            IF v_template.company_id IS NOT NULL AND v_template.company_id != v_caller_company_id THEN
                RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.company-scope-denied';
            END IF;
        END IF;
    END IF;

    -- ========================================
    -- ITEMS
    -- ========================================
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'permissionId', p.id,
            'permissionCode', p.code,
            'permissionName', p.name,
            'category', p.category,
            'addedBy', pti.added_by,
            'addedAt', pti.added_at
        ) ORDER BY p.category, p.code
    ), '[]'::jsonb)
    INTO v_items
    FROM security.permission_template_items pti
    JOIN security.permissions p ON pti.permission_id = p.id
    WHERE pti.template_id = p_id;

    -- ========================================
    -- ASSIGNMENTS (aktif atamalar)
    -- ========================================
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'assignmentId', pta.id,
            'userId', pta.user_id,
            'username', u.username,
            'assignedAt', pta.assigned_at
        ) ORDER BY pta.assigned_at DESC
    ), '[]'::jsonb)
    INTO v_assignments
    FROM security.permission_template_assignments pta
    JOIN security.users u ON pta.user_id = u.id
    WHERE pta.template_id = p_id
      AND pta.removed_at IS NULL;

    RETURN jsonb_build_object(
        'id', v_template.id,
        'code', v_template.code,
        'name', v_template.name,
        'description', v_template.description,
        'companyId', v_template.company_id,
        'isActive', v_template.is_active,
        'createdBy', v_template.created_by,
        'createdAt', v_template.created_at,
        'updatedBy', v_template.updated_by,
        'updatedAt', v_template.updated_at,
        'deletedAt', v_template.deleted_at,
        'items', v_items,
        'itemCount', jsonb_array_length(v_items),
        'assignments', v_assignments
    );
END;
$$;

COMMENT ON FUNCTION security.permission_template_get IS 'Gets template details including permission items and active assignments. IDOR protected.';
