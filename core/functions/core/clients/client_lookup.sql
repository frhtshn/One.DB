-- ================================================================
-- CLIENT_LOOKUP: Client dropdown için basit liste (IDOR korumalı)
-- Caller'ın erişebildiği client'ları döner
-- Platform Admin: Tüm client'lar (opsiyonel company filtresi)
-- CompanyAdmin: Kendi company'sindeki client'lar
-- ClientAdmin ve altı: Sadece user_allowed_clients'taki client'lar
-- ================================================================

DROP FUNCTION IF EXISTS core.client_lookup(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION core.client_lookup(
    p_caller_id BIGINT,
    p_company_id BIGINT DEFAULT NULL
)
RETURNS TABLE(
    id BIGINT,
    code VARCHAR(50),
    name VARCHAR(100),
    company_id BIGINT,
    company_name VARCHAR(100),
    is_active BOOLEAN,
    domain VARCHAR(255),
    provisioning_status VARCHAR(20)
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
              AND ur.client_id IS NULL
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

    -- Platform Admin: Tüm client'lar (opsiyonel company filtresi)
    IF v_is_platform_admin THEN
        RETURN QUERY
        SELECT
            t.id,
            t.client_code AS code,
            t.client_name AS name,
            t.company_id,
            c.company_name,
            (t.status = 1) AS is_active,
            t.domain,
            t.provisioning_status
        FROM core.clients t
        JOIN core.companies c ON c.id = t.company_id
        WHERE (p_company_id IS NULL OR t.company_id = p_company_id)
        ORDER BY c.company_name, t.client_name;
        RETURN;
    END IF;

    -- CompanyAdmin (level >= 80): Kendi company'sindeki client'lar
    IF v_caller_max_level >= 80 THEN
        RETURN QUERY
        SELECT
            t.id,
            t.client_code AS code,
            t.client_name AS name,
            t.company_id,
            c.company_name,
            (t.status = 1) AS is_active,
            t.domain,
            t.provisioning_status
        FROM core.clients t
        JOIN core.companies c ON c.id = t.company_id
        WHERE t.company_id = v_caller_company_id
          AND (p_company_id IS NULL OR t.company_id = p_company_id)
        ORDER BY t.client_name;
        RETURN;
    END IF;

    -- ClientAdmin ve altı: Sadece user_allowed_clients'taki client'lar
    RETURN QUERY
    SELECT
        t.id,
        t.client_code AS code,
        t.client_name AS name,
        t.company_id,
        c.company_name,
        (t.status = 1) AS is_active,
        t.domain,
        t.provisioning_status
    FROM core.clients t
    JOIN core.companies c ON c.id = t.company_id
    JOIN security.user_allowed_clients uat ON uat.client_id = t.id
    WHERE uat.user_id = p_caller_id
      AND (p_company_id IS NULL OR t.company_id = p_company_id)
    ORDER BY t.client_name;
END;
$$;

COMMENT ON FUNCTION core.client_lookup(BIGINT, BIGINT) IS 'Returns client list for dropdowns with IDOR protection. Platform Admin sees all, CompanyAdmin sees own company clients, others see only allowed clients.';
