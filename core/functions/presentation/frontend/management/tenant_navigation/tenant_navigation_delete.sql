-- ================================================================
-- TENANT_NAVIGATION_DELETE: Navigasyon öğesi sil
-- ================================================================
-- Açıklama:
--   Tenant navigasyon öğesini siler.
--   is_locked=TRUE olan öğeler silinemez (template'den gelen zorunlu öğeler).
-- Erişim:
--   - Platform Admin: Tüm tenant'lar
--   - CompanyAdmin: Kendi company'sindeki tenant'lar
--   - TenantAdmin: user_allowed_tenants'taki tenant'lar
-- ================================================================

DROP FUNCTION IF EXISTS presentation.tenant_navigation_delete(BIGINT, BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION presentation.tenant_navigation_delete(
    p_caller_id BIGINT,
    p_tenant_id BIGINT,
    p_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = presentation, core, security, pg_temp
AS $$
DECLARE
    v_item RECORD;
BEGIN
    -- 1. Tenant varlık kontrolü
    IF NOT EXISTS(SELECT 1 FROM core.tenants WHERE id = p_tenant_id AND status = 1) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    -- 2. Tenant erişim kontrolü
    PERFORM security.user_assert_access_tenant(p_caller_id, p_tenant_id);

    -- ========================================
    -- 3. MEVCUT ÖĞEYİ AL
    -- ========================================
    SELECT id, is_locked
    INTO v_item
    FROM presentation.tenant_navigation
    WHERE id = p_id AND tenant_id = p_tenant_id;

    IF v_item.id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant-navigation.not-found';
    END IF;

    -- ========================================
    -- 5. LOCKED KONTROLÜ
    -- ========================================
    IF v_item.is_locked THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.tenant-navigation.is-locked';
    END IF;

    -- ========================================
    -- 6. ALT ÖĞELERİ KONTROL ET
    -- ========================================
    IF EXISTS (
        SELECT 1 FROM presentation.tenant_navigation
        WHERE parent_id = p_id AND tenant_id = p_tenant_id
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.tenant-navigation.has-children';
    END IF;

    -- ========================================
    -- 7. SİL
    -- ========================================
    DELETE FROM presentation.tenant_navigation
    WHERE id = p_id AND tenant_id = p_tenant_id;
END;
$$;

COMMENT ON FUNCTION presentation.tenant_navigation_delete(BIGINT, BIGINT, BIGINT) IS
'Deletes a tenant navigation item.
Locked items (is_locked=TRUE) cannot be deleted.
Items with children cannot be deleted (delete children first).
Access: Platform Admin (all), CompanyAdmin (own company), TenantAdmin (allowed tenants).';
