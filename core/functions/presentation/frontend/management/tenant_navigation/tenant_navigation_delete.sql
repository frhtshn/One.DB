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
    v_caller_company_id BIGINT;
    v_caller_level INT;
    v_has_platform_role BOOLEAN;
    v_tenant_company_id BIGINT;
    v_has_tenant_access BOOLEAN;
    v_item RECORD;
BEGIN
    -- ========================================
    -- 1. CALLER BİLGİLERİNİ AL
    -- ========================================
    SELECT
        u.company_id,
        COALESCE(MAX(r.level), 0),
        EXISTS(
            SELECT 1 FROM security.user_roles ur2
            JOIN security.roles r2 ON ur2.role_id = r2.id AND r2.status = 1
            WHERE ur2.user_id = u.id AND ur2.tenant_id IS NULL AND r2.is_platform_role = TRUE
        )
    INTO v_caller_company_id, v_caller_level, v_has_platform_role
    FROM security.users u
    LEFT JOIN security.user_roles ur ON ur.user_id = u.id AND ur.tenant_id IS NULL
    LEFT JOIN security.roles r ON r.id = ur.role_id AND r.status = 1
    WHERE u.id = p_caller_id
      AND u.status = 1
      AND u.is_locked = FALSE
      AND (u.locked_until IS NULL OR u.locked_until < NOW())
    GROUP BY u.id, u.company_id;

    IF v_caller_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.unauthorized';
    END IF;

    -- ========================================
    -- 2. TENANT VARLIK KONTROLÜ
    -- ========================================
    SELECT company_id INTO v_tenant_company_id
    FROM core.tenants WHERE id = p_tenant_id AND status = 1;

    IF v_tenant_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    -- ========================================
    -- 3. IDOR KONTROLÜ
    -- ========================================
    IF NOT v_has_platform_role THEN
        IF v_caller_level >= 80 THEN
            IF v_tenant_company_id != v_caller_company_id THEN
                RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.company-scope-denied';
            END IF;
        ELSE
            SELECT EXISTS(
                SELECT 1 FROM security.user_allowed_tenants
                WHERE user_id = p_caller_id AND tenant_id = p_tenant_id
            ) INTO v_has_tenant_access;

            IF NOT v_has_tenant_access THEN
                RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.tenant-scope-denied';
            END IF;
        END IF;
    END IF;

    -- ========================================
    -- 4. MEVCUT ÖĞEYİ AL
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
