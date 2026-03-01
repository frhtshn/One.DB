-- ================================================================
-- COMPANY_LOOKUP: Company dropdown için basit liste (IDOR korumalı)
-- Caller'ın erişebildiği company'leri döner
-- Platform Admin: Tüm company'ler
-- CompanyAdmin ve altı: Sadece kendi company'si
-- ================================================================

DROP FUNCTION IF EXISTS core.company_lookup(BIGINT);

CREATE OR REPLACE FUNCTION core.company_lookup(
    p_caller_id BIGINT
)
RETURNS TABLE(
    id BIGINT,
    code VARCHAR(50),
    name VARCHAR(100),
    is_active BOOLEAN
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
    v_caller_company_id BIGINT;
    v_is_platform_admin BOOLEAN;
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
        )
    INTO v_caller_company_id, v_is_platform_admin
    FROM security.users u
    WHERE u.id = p_caller_id AND u.status = 1;

    IF v_caller_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.unauthorized';
    END IF;

    -- Platform Admin: Tüm company'ler
    -- Diğerleri: Sadece kendi company'si
    RETURN QUERY
    SELECT
        c.id,
        c.company_code AS code,
        c.company_name AS name,
        (c.status = 1) AS is_active
    FROM core.companies c
    WHERE v_is_platform_admin OR c.id = v_caller_company_id
    ORDER BY c.company_name;
END;
$$;

COMMENT ON FUNCTION core.company_lookup(BIGINT) IS 'Returns company list for dropdowns. Platform Admin sees all, others see only their own company.';
