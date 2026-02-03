-- ================================================================
-- TENANT_DELETE: Tenant silme (Soft Delete)
-- Status = 0 yapar.
-- GÜNCELLENDİ: Caller ID ile yetki kontrolü
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_delete(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION core.tenant_delete(p_caller_id BIGINT, p_id BIGINT)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_caller_company_id BIGINT;
    v_has_platform_role BOOLEAN;
    v_tenant_company_id BIGINT;
    v_tenant_status SMALLINT;
BEGIN
    -- 1. Yetki ve Kullanıcı Kontrolü
    SELECT
        u.company_id,
        EXISTS(SELECT 1 FROM security.user_roles ur JOIN security.roles r ON ur.role_id = r.id WHERE ur.user_id = u.id AND ur.tenant_id IS NULL AND r.is_platform_role = TRUE)
    INTO v_caller_company_id, v_has_platform_role
    FROM security.users u
    WHERE u.id = p_caller_id AND u.status = 1;

    IF v_caller_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.unauthorized';
    END IF;

    -- 2. Tenant Varlık Kontrolü
    SELECT company_id, status INTO v_tenant_company_id, v_tenant_status
    FROM core.tenants
    WHERE id = p_id;

    IF NOT FOUND THEN
         RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    -- 3. Scope Kontrolü
    IF NOT v_has_platform_role THEN
        IF v_tenant_company_id != v_caller_company_id THEN
            RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.company-scope-denied';
        END IF;
    END IF;

    -- 4. Silinmiş Kontrolü
    IF v_tenant_status = 0 THEN
         RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.tenant.already-deleted';
    END IF;

    -- Soft Delete
    UPDATE core.tenants
    SET status = 0,
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION core.tenant_delete(BIGINT, BIGINT) IS 'Soft deletes a tenant. Checks caller permissions.';
