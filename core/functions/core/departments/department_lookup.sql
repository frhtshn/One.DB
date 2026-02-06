-- ================================================================
-- DEPARTMENT_LOOKUP: Departman dropdown listesi
-- Şirkete ait aktif departmanları basit formatta döner
-- p_lang verilirse çözülmüş string döner, NULL ise tam JSONB döner
-- Erişim: Platform Admin (tüm şirketler), CompanyAdmin (kendi şirketi)
-- IDOR korumalı: user_assert_access_company
-- ================================================================

DROP FUNCTION IF EXISTS core.department_lookup(BIGINT, BIGINT, CHAR);

CREATE OR REPLACE FUNCTION core.department_lookup(
    p_caller_id BIGINT,
    p_company_id BIGINT,
    p_lang CHAR(2) DEFAULT NULL            -- NULL = tam JSONB, 'tr' = çözülmüş string (en fallback)
)
RETURNS TABLE(
    id BIGINT,
    code VARCHAR(50),
    name JSONB,
    parent_id BIGINT
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = core, security, pg_temp
AS $$
BEGIN
    -- 1. Şirket erişim kontrolü (IDOR)
    PERFORM security.user_assert_access_company(p_caller_id, p_company_id);

    -- 2. Aktif departmanları döndür
    RETURN QUERY
    SELECT
        d.id,
        d.code,
        CASE
            WHEN p_lang IS NOT NULL THEN to_jsonb(COALESCE(d.name ->> p_lang, d.name ->> 'en'))
            ELSE d.name
        END,
        d.parent_id
    FROM core.departments d
    WHERE d.company_id = p_company_id
      AND d.is_active = TRUE
    ORDER BY d.code;
END;
$$;

COMMENT ON FUNCTION core.department_lookup(BIGINT, BIGINT, CHAR) IS
'Returns active departments for dropdowns.
p_lang=NULL: name returns full JSONB ({"en": "IT", "tr": "BT"}).
p_lang="tr": name returns resolved string as JSONB ("BT") with "en" fallback.
Access: Platform Admin (all companies), CompanyAdmin (own company). IDOR protected.';
