-- ================================================================
-- PERMISSION_TEMPLATE_UNASSIGN: Template kaldirma
-- ================================================================
-- Akis:
--   1. Assignment kaydini bul (removed_at IS NULL)
--   2. template_assignment_id ile iliskili override'lari SIL
--   3. Assignment'i soft-delete (removed_at, removed_by, removal_reason)
-- ================================================================

DROP FUNCTION IF EXISTS security.permission_template_unassign(BIGINT, BIGINT, BIGINT, TEXT);

CREATE OR REPLACE FUNCTION security.permission_template_unassign(
    p_assignment_id BIGINT,
    p_user_id BIGINT,
    p_caller_id BIGINT,
    p_removal_reason TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_assignment RECORD;
    v_caller_company_id BIGINT;
    v_target_company_id BIGINT;
    v_has_platform_role BOOLEAN;
    v_deleted_overrides INT;
BEGIN
    -- ========================================
    -- 1. ASSIGNMENT KONTROLU
    -- ========================================
    SELECT id, user_id, template_id, tenant_id, removed_at
    INTO v_assignment
    FROM security.permission_template_assignments
    WHERE id = p_assignment_id AND user_id = p_user_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.permission-template.assignment-not-found';
    END IF;

    IF v_assignment.removed_at IS NOT NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.permission-template.assignment-already-removed';
    END IF;

    -- ========================================
    -- 2. IDOR KONTROLU
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
        WHERE ur.user_id = p_caller_id AND ur.tenant_id IS NULL AND r.is_platform_role = TRUE
    ) INTO v_has_platform_role;

    IF NOT v_has_platform_role THEN
        IF v_target_company_id != v_caller_company_id THEN
            RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.user-scope-denied';
        END IF;
    END IF;

    -- ========================================
    -- 3. OVERRIDE'LARI SIL (template_assignment_id ile)
    -- ========================================
    DELETE FROM security.user_permission_overrides
    WHERE template_assignment_id = p_assignment_id;

    GET DIAGNOSTICS v_deleted_overrides = ROW_COUNT;

    -- ========================================
    -- 4. ASSIGNMENT SOFT-DELETE
    -- ========================================
    UPDATE security.permission_template_assignments
    SET
        removed_at = NOW(),
        removed_by = p_caller_id,
        removal_reason = p_removal_reason
    WHERE id = p_assignment_id;

    RETURN jsonb_build_object(
        'assignmentId', p_assignment_id,
        'deletedOverrides', v_deleted_overrides,
        'removedAt', NOW()
    );
END;
$$;

COMMENT ON FUNCTION security.permission_template_unassign IS
'Removes a template assignment. Deletes associated override rows and soft-deletes the assignment record. IDOR protected.';
