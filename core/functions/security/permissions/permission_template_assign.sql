-- ================================================================
-- PERMISSION_TEMPLATE_ASSIGN: Template atama (Expansion + Snapshot)
-- ================================================================
-- Akis:
--   1. Template aktif mi kontrol et
--   2. Duplicate assignment kontrolu (409 Conflict)
--   3. Privilege escalation kontrolu (caller'da olmayan permission veremez)
--   4. Hedef user'in rol + override'larini al
--   5. Her item icin: redundant → SKIP, yoksa → INSERT override
--   6. Assignment kaydi + JSONB snapshot'lar
-- ================================================================

DROP FUNCTION IF EXISTS security.permission_template_assign(BIGINT, BIGINT, BIGINT, BIGINT, TIMESTAMPTZ, TEXT);

CREATE OR REPLACE FUNCTION security.permission_template_assign(
    p_template_id BIGINT,
    p_user_id BIGINT,
    p_caller_id BIGINT,
    p_tenant_id BIGINT DEFAULT NULL,
    p_expires_at TIMESTAMPTZ DEFAULT NULL,
    p_reason TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_template RECORD;
    v_caller_company_id BIGINT;
    v_target_company_id BIGINT;
    v_has_platform_role BOOLEAN;
    v_assignment_id BIGINT;
    v_template_snapshot JSONB;
    v_assigned_permissions JSONB := '[]'::jsonb;
    v_skipped_permissions JSONB := '[]'::jsonb;
    v_assigned_count INT := 0;
    v_skipped_count INT := 0;
    v_item RECORD;
    v_in_role BOOLEAN;
    v_in_override BOOLEAN;
    v_tenant_company_id BIGINT;
BEGIN
    -- ========================================
    -- 1. TEMPLATE KONTROLU
    -- ========================================
    SELECT id, code, name, description, company_id, is_active, deleted_at
    INTO v_template
    FROM security.permission_templates
    WHERE id = p_template_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.permission-template.not-found';
    END IF;

    IF v_template.deleted_at IS NOT NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.permission-template.deleted';
    END IF;

    IF NOT v_template.is_active THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.permission-template.inactive';
    END IF;

    -- ========================================
    -- 2. HEDEF USER KONTROLU
    -- ========================================
    SELECT u.company_id FROM security.users u
    WHERE u.id = p_user_id AND u.status = 1
    INTO v_target_company_id;

    IF v_target_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
    END IF;

    -- ========================================
    -- 3. IDOR KONTROLU
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
        -- Ayni sirketten mi?
        IF v_target_company_id != v_caller_company_id THEN
            RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.user-scope-denied';
        END IF;

        -- Company template: kendi sirketinin template'i mi?
        IF v_template.company_id IS NOT NULL AND v_template.company_id != v_caller_company_id THEN
            RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.company-scope-denied';
        END IF;

        -- Tenant validation: tenant kendi sirketine ait mi?
        IF p_tenant_id IS NOT NULL THEN
            SELECT t.company_id FROM core.tenants t
            WHERE t.id = p_tenant_id AND t.status = 1
            INTO v_tenant_company_id;

            IF v_tenant_company_id IS NULL THEN
                RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
            END IF;

            IF v_tenant_company_id != v_caller_company_id THEN
                RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.tenant-scope-denied';
            END IF;
        END IF;
    END IF;

    -- ========================================
    -- 4. DUPLICATE ASSIGNMENT KONTROLU (409)
    -- ========================================
    IF EXISTS(
        SELECT 1 FROM security.permission_template_assignments
        WHERE template_id = p_template_id
          AND user_id = p_user_id
          AND removed_at IS NULL
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.permission-template.already-assigned';
    END IF;

    -- ========================================
    -- 5. PRIVILEGE ESCALATION KONTROLU
    -- ========================================
    IF NOT v_has_platform_role THEN
        -- Template'deki HER permission caller'da var mi?
        IF EXISTS(
            SELECT 1
            FROM security.permission_template_items pti
            JOIN security.permissions p ON pti.permission_id = p.id
            WHERE pti.template_id = p_template_id
              AND NOT security.permission_check(p_caller_id, p.code, p_tenant_id)
        ) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.auth.permission-escalation';
        END IF;
    END IF;

    -- ========================================
    -- 6. TEMPLATE SNAPSHOT
    -- ========================================
    v_template_snapshot := jsonb_build_object(
        'id', v_template.id,
        'code', v_template.code,
        'name', v_template.name,
        'description', v_template.description
    );

    -- ========================================
    -- 7. ASSIGNMENT KAYDI OLUSTUR (once ID lazim)
    -- ========================================
    INSERT INTO security.permission_template_assignments (
        user_id, template_id, tenant_id, template_snapshot,
        assigned_permissions, skipped_permissions,
        assigned_by, expires_at, reason
    ) VALUES (
        p_user_id, p_template_id, p_tenant_id, v_template_snapshot,
        '[]'::jsonb, '[]'::jsonb,
        p_caller_id, p_expires_at, p_reason
    )
    RETURNING id INTO v_assignment_id;

    -- ========================================
    -- 8. EXPANSION: Her item icin override olustur veya atla
    -- ========================================
    FOR v_item IN
        SELECT pti.permission_id, p.code AS permission_code, p.name AS permission_name
        FROM security.permission_template_items pti
        JOIN security.permissions p ON pti.permission_id = p.id AND p.status = 1
        WHERE pti.template_id = p_template_id
        ORDER BY p.code
    LOOP
        -- Hedef user'in rolunde bu permission var mi?
        v_in_role := EXISTS(
            SELECT 1
            FROM security.role_permissions rp
            JOIN security.user_roles ur ON rp.role_id = ur.role_id
            JOIN security.roles r ON ur.role_id = r.id AND r.status = 1
            WHERE ur.user_id = p_user_id
              AND rp.permission_id = v_item.permission_id
              AND (ur.tenant_id IS NULL OR ur.tenant_id = p_tenant_id OR p_tenant_id IS NULL)
        );

        -- Hedef user'in mevcut override'inda bu permission var mi? (context_id IS NULL, global)
        v_in_override := EXISTS(
            SELECT 1
            FROM security.user_permission_overrides upo
            WHERE upo.user_id = p_user_id
              AND upo.permission_id = v_item.permission_id
              AND upo.context_id IS NULL
              AND (upo.expires_at IS NULL OR upo.expires_at > NOW())
        );

        IF v_in_role THEN
            -- SKIP: Rolde zaten var
            v_skipped_permissions := v_skipped_permissions || jsonb_build_object(
                'id', v_item.permission_id,
                'code', v_item.permission_code,
                'reason', 'role'
            );
            v_skipped_count := v_skipped_count + 1;

        ELSIF v_in_override THEN
            -- SKIP: Override'da zaten var
            v_skipped_permissions := v_skipped_permissions || jsonb_build_object(
                'id', v_item.permission_id,
                'code', v_item.permission_code,
                'reason', 'override'
            );
            v_skipped_count := v_skipped_count + 1;

        ELSE
            -- INSERT override
            INSERT INTO security.user_permission_overrides (
                user_id, permission_id, tenant_id, context_id, is_granted,
                reason, assigned_by, expires_at, template_assignment_id
            ) VALUES (
                p_user_id, v_item.permission_id, p_tenant_id, NULL, TRUE,
                'Template: ' || v_template.code, p_caller_id, p_expires_at, v_assignment_id
            );

            v_assigned_permissions := v_assigned_permissions || jsonb_build_object(
                'id', v_item.permission_id,
                'code', v_item.permission_code
            );
            v_assigned_count := v_assigned_count + 1;
        END IF;
    END LOOP;

    -- ========================================
    -- 9. ASSIGNMENT KAYDINI GUNCELLE (snapshot'lar)
    -- ========================================
    UPDATE security.permission_template_assignments
    SET
        assigned_permissions = v_assigned_permissions,
        skipped_permissions = v_skipped_permissions
    WHERE id = v_assignment_id;

    -- ========================================
    -- 10. SONUC
    -- ========================================
    RETURN jsonb_build_object(
        'assignmentId', v_assignment_id,
        'assignedCount', v_assigned_count,
        'skippedCount', v_skipped_count,
        'assignedPermissions', v_assigned_permissions,
        'skippedPermissions', v_skipped_permissions
    );
END;
$$;

COMMENT ON FUNCTION security.permission_template_assign IS
'Assigns a template to a user via expansion model. Each template permission becomes an override row.
Skips permissions already in user role or existing overrides. IDOR + Privilege Escalation protected.
Returns assignment result with assigned/skipped counts and details.';
