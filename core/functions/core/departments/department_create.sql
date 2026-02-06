-- ================================================================
-- DEPARTMENT_CREATE: Yeni departman oluştur
-- Şirket bazında yeni departman ekler
-- name ve description çoklu dil destekli (TEXT → JSONB cast)
-- Erişim: Platform Admin (tüm şirketler), CompanyAdmin (kendi şirketi)
-- IDOR korumalı: user_assert_access_company
-- ================================================================

DROP FUNCTION IF EXISTS core.department_create(BIGINT, BIGINT, VARCHAR, TEXT, BIGINT, TEXT);

CREATE OR REPLACE FUNCTION core.department_create(
    p_caller_id BIGINT,
    p_company_id BIGINT,
    p_code VARCHAR(50),
    p_name TEXT,                            -- Çoklu dil: '{"en": "IT", "tr": "BT"}'
    p_parent_id BIGINT DEFAULT NULL,
    p_description TEXT DEFAULT NULL          -- Çoklu dil: '{"en": "...", "tr": "..."}'
)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = core, security, pg_temp
AS $$
DECLARE
    v_id BIGINT;
BEGIN
    -- 1. Şirket varlık kontrolü
    IF NOT EXISTS (SELECT 1 FROM core.companies WHERE id = p_company_id AND status = 1) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.company.not-found';
    END IF;

    -- 2. Şirket erişim kontrolü (IDOR)
    PERFORM security.user_assert_access_company(p_caller_id, p_company_id);

    -- 3. Kod benzersizliği kontrolü (company bazında)
    IF EXISTS (SELECT 1 FROM core.departments WHERE company_id = p_company_id AND code = UPPER(TRIM(p_code))) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.department.create.code-exists';
    END IF;

    -- 4. Parent varlık kontrolü (aynı şirkette olmalı)
    IF p_parent_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM core.departments
            WHERE id = p_parent_id AND company_id = p_company_id AND is_active = TRUE
        ) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.department.parent-not-found';
        END IF;
    END IF;

    -- 5. Departman oluştur
    INSERT INTO core.departments (company_id, parent_id, code, name, description, is_active, created_at, updated_at)
    VALUES (
        p_company_id,
        p_parent_id,
        UPPER(TRIM(p_code)),
        p_name::jsonb,
        CASE WHEN p_description IS NOT NULL THEN p_description::jsonb ELSE '{}'::jsonb END,
        TRUE,
        NOW(),
        NOW()
    )
    RETURNING id INTO v_id;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION core.department_create(BIGINT, BIGINT, VARCHAR, TEXT, BIGINT, TEXT) IS
'Creates a new department for a company. Code is unique per company (stored uppercase).
name and description are multi-language JSONB (e.g. {"en": "IT", "tr": "BT"}), received as TEXT.
Access: Platform Admin (all companies), CompanyAdmin (own company). IDOR protected.';
