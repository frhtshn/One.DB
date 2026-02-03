-- ================================================================
-- TENANT_LOOKUP: Tenant dropdown için basit liste (IDOR korumalı)
-- Caller'ın erişebildiği tenant'ları döner
-- Platform Admin: Tüm tenant'lar (opsiyonel company filtresi)
-- CompanyAdmin: Kendi company'sindeki tenant'lar
-- TenantAdmin ve altı: Sadece user_allowed_tenants'taki tenant'lar
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_lookup(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION core.tenant_lookup(
    p_caller_id BIGINT,
    p_company_id BIGINT DEFAULT NULL
)
RETURNS TABLE(
    id BIGINT,
    code VARCHAR(50),
    name VARCHAR(100),
    company_id BIGINT,
    company_name VARCHAR(100),
    is_active BOOLEAN
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
    v_caller_company_id BIGINT;
    v_is_platform_admin BOOLEAN;
    v_caller_max_level INT;
BEGIN
    -- Caller bilgilerini al
    SELECT
        u.company_id,
        EXISTS(
            SELECT 1 FROM security.user_roles ur
            JOIN security.roles r ON ur.role_id = r.id
            WHERE ur.user_id = u.id
              AND ur.tenant_id IS NULL
              AND r.is_platform_role = TRUE
              AND r.status = 1
        ),
        COALESCE((
            SELECT MAX(r.level) FROM security.user_roles ur
            JOIN security.roles r ON ur.role_id = r.id
            WHERE ur.user_id = u.id AND r.status = 1
        ), 0)
    INTO v_caller_company_id, v_is_platform_admin, v_caller_max_level
    FROM security.users u
    WHERE u.id = p_caller_id AND u.status = 1;

    IF v_caller_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.unauthorized';
    END IF;

    -- Platform Admin: Tüm tenant'lar (opsiyonel company filtresi)
    IF v_is_platform_admin THEN
        RETURN QUERY
        SELECT
            t.id,
            t.tenant_code AS code,
            t.tenant_name AS name,
            t.company_id,
            c.company_name,
            (t.status = 1) AS is_active
        FROM core.tenants t
        JOIN core.companies c ON c.id = t.company_id
        WHERE (p_company_id IS NULL OR t.company_id = p_company_id)
        ORDER BY c.company_name, t.tenant_name;
        RETURN;
    END IF;

    -- CompanyAdmin (level >= 80): Kendi company'sindeki tenant'lar
    IF v_caller_max_level >= 80 THEN
        RETURN QUERY
        SELECT
            t.id,
            t.tenant_code AS code,
            t.tenant_name AS name,
            t.company_id,
            c.company_name,
            (t.status = 1) AS is_active
        FROM core.tenants t
        JOIN core.companies c ON c.id = t.company_id
        WHERE t.company_id = v_caller_company_id
          AND (p_company_id IS NULL OR t.company_id = p_company_id)
        ORDER BY t.tenant_name;
        RETURN;
    END IF;

    -- TenantAdmin ve altı: Sadece user_allowed_tenants'taki tenant'lar
    RETURN QUERY
    SELECT
        t.id,
        t.tenant_code AS code,
        t.tenant_name AS name,
        t.company_id,
        c.company_name,
        (t.status = 1) AS is_active
    FROM core.tenants t
    JOIN core.companies c ON c.id = t.company_id
    JOIN security.user_allowed_tenants uat ON uat.tenant_id = t.id
    WHERE uat.user_id = p_caller_id
      AND (p_company_id IS NULL OR t.company_id = p_company_id)
    ORDER BY t.tenant_name;
END;
$$;

COMMENT ON FUNCTION core.tenant_lookup(BIGINT, BIGINT) IS 'Returns tenant list for dropdowns with IDOR protection. Platform Admin sees all, CompanyAdmin sees own company tenants, others see only allowed tenants.';
