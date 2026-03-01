-- ================================================================
-- PERMISSION_TEMPLATE_ASSIGNMENT_LIST: User'in template atamalari
-- IDOR: Company + Client scope kontrolu
-- Returns: JSONB - aktif atamalar listesi
-- ================================================================

DROP FUNCTION IF EXISTS security.permission_template_assignment_list(BIGINT, BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION security.permission_template_assignment_list(
    p_caller_id BIGINT,
    p_user_id BIGINT,
    p_client_id BIGINT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_caller_company_id BIGINT;
    v_target_company_id BIGINT;
    v_has_platform_role BOOLEAN;
    v_items JSONB;
BEGIN
    -- ========================================
    -- IDOR KONTROLU
    -- ========================================
    SELECT u.company_id FROM security.users u
    WHERE u.id = p_caller_id AND u.status = 1
    INTO v_caller_company_id;

    IF v_caller_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.unauthorized';
    END IF;

    SELECT u.company_id FROM security.users u
    WHERE u.id = p_user_id AND u.status = 1
    INTO v_target_company_id;

    IF v_target_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
    END IF;

    SELECT EXISTS(
        SELECT 1 FROM security.user_roles ur
        JOIN security.roles r ON ur.role_id = r.id
        WHERE ur.user_id = p_caller_id AND ur.client_id IS NULL AND r.is_platform_role = TRUE
    ) INTO v_has_platform_role;

    IF NOT v_has_platform_role THEN
        IF v_target_company_id != v_caller_company_id THEN
            RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.user-scope-denied';
        END IF;
    END IF;

    -- ========================================
    -- ATAMA LISTESI
    -- ========================================
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', pta.id,
            'templateId', pta.template_id,
            'templateSnapshot', pta.template_snapshot,
            'clientId', pta.client_id,
            'assignedPermissions', pta.assigned_permissions,
            'skippedPermissions', pta.skipped_permissions,
            'assignedBy', pta.assigned_by,
            'assignedAt', pta.assigned_at,
            'expiresAt', pta.expires_at,
            'reason', pta.reason,
            'removedAt', pta.removed_at,
            'removedBy', pta.removed_by,
            'removalReason', pta.removal_reason
        ) ORDER BY pta.assigned_at DESC
    ), '[]'::jsonb)
    INTO v_items
    FROM security.permission_template_assignments pta
    WHERE pta.user_id = p_user_id
      AND pta.removed_at IS NULL
      AND (p_client_id IS NULL OR pta.client_id = p_client_id);

    RETURN jsonb_build_object(
        'userId', p_user_id,
        'items', v_items
    );
END;
$$;

COMMENT ON FUNCTION security.permission_template_assignment_list IS
'Lists template assignments for a user (active + removed). IDOR protected.';
