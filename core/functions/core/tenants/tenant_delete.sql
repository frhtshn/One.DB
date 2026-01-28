-- ================================================================
-- TENANT_DELETE: Tenant silme (Soft Delete)
-- Status = 0 yapar.
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_delete(BIGINT);

CREATE OR REPLACE FUNCTION core.tenant_delete(p_id BIGINT)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Existence Check
    IF NOT EXISTS (SELECT 1 FROM core.tenants WHERE id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    -- Already deleted check
    IF EXISTS (SELECT 1 FROM core.tenants WHERE id = p_id AND status = 0) THEN
         RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.tenant.already-deleted';
    END IF;

    -- Soft Delete
    UPDATE core.tenants
    SET status = 0,
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION core.tenant_delete(BIGINT) IS 'Soft deletes a tenant by setting status to 0.';
