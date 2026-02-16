-- ================================================================
-- PERMISSION_TEMPLATE_ITEM_SET: Bulk permission ekle/cikar
-- p_action: 'add' veya 'remove'
-- p_permission_ids: Permission ID dizisi
-- IDOR: Company scope kontrolu
-- Returns: JSONB - etkilenen permission sayisi
-- ================================================================

DROP FUNCTION IF EXISTS security.permission_template_item_set(BIGINT, BIGINT[], VARCHAR, BIGINT);

CREATE OR REPLACE FUNCTION security.permission_template_item_set(
    p_template_id BIGINT,
    p_permission_ids BIGINT[],
    p_action VARCHAR(10) DEFAULT 'add',
    p_caller_id BIGINT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_template RECORD;
    v_caller_company_id BIGINT;
    v_has_platform_role BOOLEAN;
    v_affected_count INT := 0;
    v_pid BIGINT;
BEGIN
    -- Template var mi ve silinmemis mi?
    SELECT id, company_id, deleted_at, is_active
    INTO v_template
    FROM security.permission_templates
    WHERE id = p_template_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.permission-template.not-found';
    END IF;

    IF v_template.deleted_at IS NOT NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.permission-template.deleted';
    END IF;

    -- Bos liste kontrolu
    IF p_permission_ids IS NULL OR array_length(p_permission_ids, 1) IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.permission-template.items-required';
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
            IF v_template.company_id IS NULL THEN
                RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.permission-denied';
            END IF;

            IF v_template.company_id != v_caller_company_id THEN
                RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.company-scope-denied';
            END IF;
        END IF;
    END IF;

    -- ========================================
    -- ADD / REMOVE ISLEMI
    -- ========================================
    IF LOWER(p_action) = 'add' THEN
        -- Gecerli permission'lari filtrele (status=1)
        INSERT INTO security.permission_template_items (template_id, permission_id, added_by, added_at)
        SELECT p_template_id, p.id, COALESCE(p_caller_id, 0), NOW()
        FROM security.permissions p
        WHERE p.id = ANY(p_permission_ids) AND p.status = 1
        ON CONFLICT (template_id, permission_id) DO NOTHING;

        GET DIAGNOSTICS v_affected_count = ROW_COUNT;

    ELSIF LOWER(p_action) = 'remove' THEN
        DELETE FROM security.permission_template_items
        WHERE template_id = p_template_id
          AND permission_id = ANY(p_permission_ids);

        GET DIAGNOSTICS v_affected_count = ROW_COUNT;
    ELSE
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.permission-template.invalid-action';
    END IF;

    -- Template updated_at guncelle
    UPDATE security.permission_templates
    SET updated_by = p_caller_id, updated_at = NOW()
    WHERE id = p_template_id;

    RETURN jsonb_build_object(
        'templateId', p_template_id,
        'action', p_action,
        'affectedCount', v_affected_count
    );
END;
$$;

COMMENT ON FUNCTION security.permission_template_item_set IS 'Bulk add or remove permissions from a template. IDOR protected.';
