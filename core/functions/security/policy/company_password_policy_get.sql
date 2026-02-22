-- ================================================================
-- COMPANY_PASSWORD_POLICY_GET: Company şifre politikasını getir (IDOR Korumalı)
-- ================================================================
-- Erişim Kuralları:
--   - Platform Admin (SuperAdmin/Admin): Herhangi bir company'nin politikasını görebilir
--   - CompanyAdmin: Sadece kendi company'sinin politikasını görebilir
--   - Diğerleri: ERİŞİM YOK
-- Response:
--   - Policy varsa döner, yoksa platform default değerler döner
-- ================================================================

DROP FUNCTION IF EXISTS security.company_password_policy_get(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION security.company_password_policy_get(
    p_caller_id  BIGINT,
    p_company_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = security, core, pg_temp
AS $$
DECLARE
    v_result JSONB;
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
    -- 3. POLİTİKAYI GETİR (veya default)
    -- ========================================
    SELECT jsonb_build_object(
        'companyId',              p_company_id,
        'expiryDays',             COALESCE(cpp.expiry_days, 30),
        'historyCount',           COALESCE(cpp.history_count, 3),
        'minLength',              COALESCE(cpp.min_length, 8),
        'requireUppercase',       COALESCE(cpp.require_uppercase, TRUE),
        'requireLowercase',       COALESCE(cpp.require_lowercase, TRUE),
        'requireDigit',           COALESCE(cpp.require_digit, TRUE),
        'requireSpecial',         COALESCE(cpp.require_special, FALSE),
        'maxLoginAttempts',       COALESCE(cpp.max_login_attempts, 5),
        'lockoutDurationMinutes', COALESCE(cpp.lockout_duration_minutes, 30),
        'hasCustomPolicy',        (cpp.company_id IS NOT NULL),
        'createdAt',              cpp.created_at,
        'createdBy',              cpp.created_by,
        'updatedAt',              cpp.updated_at,
        'updatedBy',              cpp.updated_by
    )
    INTO v_result
    FROM (SELECT p_company_id AS company_id) req
    LEFT JOIN security.company_password_policy cpp ON cpp.company_id = req.company_id;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION security.company_password_policy_get(BIGINT, BIGINT) IS
'Returns company password policy with IDOR protection.
Access: Platform Admin (any company), CompanyAdmin (own company only).
If no custom policy exists, returns platform defaults (expiryDays=30, historyCount=3, minLength=8, etc.).
hasCustomPolicy field indicates whether company has a custom policy.';
