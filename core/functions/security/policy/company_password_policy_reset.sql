-- ================================================================
-- COMPANY_PASSWORD_POLICY_RESET: Company şifre politikasını sil (default'a döndür)
-- ================================================================
-- Erişim Kuralları:
--   - Platform Admin (SuperAdmin/Admin): Herhangi bir company'nin politikasını sıfırlayabilir
--   - CompanyAdmin: Sadece kendi company'sini sıfırlayabilir
--   - Diğerleri: ERİŞİM YOK
-- Davranış:
--   - security.company_password_policy'den satırı DELETE eder
--   - Satır yoksa sessizce başarılı döner (idempotent)
--   - Sıfırlama sonrası platform default değerleri geçerli olur
-- ================================================================

DROP FUNCTION IF EXISTS security.company_password_policy_reset(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION security.company_password_policy_reset(
    p_caller_id  BIGINT,
    p_company_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = security, core, pg_temp
AS $$
BEGIN
    -- ========================================
    -- 1. IDOR KONTROLÜ (Helper ile)
    -- ========================================
    PERFORM security.user_assert_access_company(p_caller_id, p_company_id);

    -- ========================================
    -- 2. COMPANY VARLIK KONTROLÜ
    -- ========================================
    IF NOT EXISTS (SELECT 1 FROM core.companies WHERE id = p_company_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.company.not-found';
    END IF;

    -- ========================================
    -- 3. POLİTİKAYI SİL (idempotent — yoksa hata vermez)
    -- ========================================
    DELETE FROM security.company_password_policy
    WHERE company_id = p_company_id;
END;
$$;

COMMENT ON FUNCTION security.company_password_policy_reset(BIGINT, BIGINT) IS
'Deletes company custom password policy, reverting to platform defaults.
Access: Platform Admin (any company), CompanyAdmin (own company only).
Idempotent: no error if policy does not exist.
After reset, platform defaults apply (expiryDays=30, minLength=8, etc.).';
