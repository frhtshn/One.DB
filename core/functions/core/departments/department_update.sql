-- ================================================================
-- DEPARTMENT_UPDATE: Departman güncelle
-- Departman bilgilerini günceller (COALESCE pattern)
-- name ve description çoklu dil destekli (TEXT → JSONB cast)
-- Erişim: Platform Admin (tüm şirketler), CompanyAdmin (kendi şirketi)
-- IDOR korumalı: user_assert_access_company
-- ================================================================

DROP FUNCTION IF EXISTS core.department_update(BIGINT, BIGINT, BIGINT, VARCHAR, TEXT, BIGINT, TEXT, BOOLEAN);

CREATE OR REPLACE FUNCTION core.department_update(
    p_caller_id BIGINT,
    p_company_id BIGINT,
    p_id BIGINT,
    p_code VARCHAR(50) DEFAULT NULL,
    p_name TEXT DEFAULT NULL,               -- Çoklu dil: '{"en": "IT", "tr": "BT"}'
    p_parent_id BIGINT DEFAULT NULL,
    p_description TEXT DEFAULT NULL,         -- Çoklu dil: '{"en": "...", "tr": "..."}'
    p_is_active BOOLEAN DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = core, security, pg_temp
AS $$
BEGIN
    -- 1. Şirket erişim kontrolü (IDOR)
    PERFORM security.user_assert_access_company(p_caller_id, p_company_id);

    -- 2. Departman varlık kontrolü
    IF NOT EXISTS (SELECT 1 FROM core.departments WHERE id = p_id AND company_id = p_company_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.department.not-found';
    END IF;

    -- 3. Kod benzersizliği kontrolü (değiştiriliyorsa)
    IF p_code IS NOT NULL THEN
        IF EXISTS (SELECT 1 FROM core.departments WHERE company_id = p_company_id AND code = UPPER(TRIM(p_code)) AND id <> p_id) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.department.update.code-exists';
        END IF;
    END IF;

    -- 4. Parent varlık kontrolü (değiştiriliyorsa)
    IF p_parent_id IS NOT NULL THEN
        -- Kendisini parent yapamaz
        IF p_parent_id = p_id THEN
            RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.department.self-parent';
        END IF;

        -- Parent aynı şirkette ve aktif olmalı
        IF NOT EXISTS (
            SELECT 1 FROM core.departments
            WHERE id = p_parent_id AND company_id = p_company_id AND is_active = TRUE
        ) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.department.parent-not-found';
        END IF;
    END IF;

    -- 5. Güncelle
    UPDATE core.departments
    SET
        code = COALESCE(UPPER(TRIM(p_code)), code),
        name = CASE WHEN p_name IS NOT NULL THEN p_name::jsonb ELSE name END,
        parent_id = COALESCE(p_parent_id, parent_id),
        description = CASE WHEN p_description IS NOT NULL THEN p_description::jsonb ELSE description END,
        is_active = COALESCE(p_is_active, is_active),
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION core.department_update(BIGINT, BIGINT, BIGINT, VARCHAR, TEXT, BIGINT, TEXT, BOOLEAN) IS
'Updates department information. name and description are multi-language JSONB, received as TEXT.
COALESCE pattern: only provided fields are updated.
Access: Platform Admin (all companies), CompanyAdmin (own company). IDOR protected.';
