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
    v_tenant_company_id BIGINT;
    v_tenant_status SMALLINT;
BEGIN
    -- 1. Tenant varlık kontrolü
    SELECT company_id, status INTO v_tenant_company_id, v_tenant_status
    FROM core.tenants WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    -- 2. Company erişim kontrolü
    PERFORM security.user_assert_access_company(p_caller_id, v_tenant_company_id);

    -- 3. Silinmiş kontrolü
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
