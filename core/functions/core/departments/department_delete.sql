-- ================================================================
-- DEPARTMENT_DELETE: Departman sil (soft delete)
-- is_active = FALSE olarak işaretler
-- Erişim: Platform Admin (tüm şirketler), CompanyAdmin (kendi şirketi)
-- IDOR korumalı: user_assert_access_company
-- ================================================================

DROP FUNCTION IF EXISTS core.department_delete(BIGINT, BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION core.department_delete(
    p_caller_id BIGINT,
    p_company_id BIGINT,
    p_id BIGINT
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

    -- 3. Zaten silinmiş mi?
    IF EXISTS (SELECT 1 FROM core.departments WHERE id = p_id AND is_active = FALSE) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.department.delete.already-deleted';
    END IF;

    -- 4. Alt departman kontrolü (aktif alt departman varsa silemez)
    IF EXISTS (SELECT 1 FROM core.departments WHERE parent_id = p_id AND is_active = TRUE) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.department.delete.has-children';
    END IF;

    -- 5. Soft delete
    UPDATE core.departments
    SET is_active = FALSE, updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION core.department_delete(BIGINT, BIGINT, BIGINT) IS
'Soft deletes a department (is_active = FALSE). Fails if active child departments exist.
Access: Platform Admin (all companies), CompanyAdmin (own company). IDOR protected.';
