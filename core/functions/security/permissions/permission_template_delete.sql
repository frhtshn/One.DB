-- ================================================================
-- PERMISSION_TEMPLATE_DELETE: Soft-delete (hard delete YASAK)
-- deleted_at/deleted_by ile audit trail korunur
-- Silinen template'e yeni atama yapilamaz, mevcut atamalar korunur
-- IDOR: Company scope kontrolu
-- Returns: VOID
-- ================================================================

DROP FUNCTION IF EXISTS security.permission_template_delete(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION security.permission_template_delete(
    p_id BIGINT,
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
    -- Template var mi?
    SELECT id, company_id, deleted_at
    INTO v_template
    FROM security.permission_templates
    WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.permission-template.not-found';
    END IF;

    -- Zaten silinmis mi?
    IF v_template.deleted_at IS NOT NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.permission-template.already-deleted';
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
            WHERE ur.user_id = p_caller_id AND ur.client_id IS NULL AND r.is_platform_role = TRUE
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
    -- SOFT DELETE
    -- ========================================
    UPDATE security.permission_templates
    SET
        deleted_at = NOW(),
        deleted_by = COALESCE(p_caller_id, 0)
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION security.permission_template_delete IS 'Soft-deletes a permission template. Hard delete is prohibited. Existing assignments are preserved.';
