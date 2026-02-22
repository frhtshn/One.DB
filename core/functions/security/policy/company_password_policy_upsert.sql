-- ================================================================
-- COMPANY_PASSWORD_POLICY_UPSERT: Company şifre politikasını oluştur/güncelle (IDOR Korumalı)
-- ================================================================
-- Erişim Kuralları:
--   - Platform Admin (SuperAdmin/Admin): Herhangi bir company'nin politikasını düzenleyebilir
--   - CompanyAdmin: Sadece kendi company'sinin politikasını düzenleyebilir
--   - Diğerleri: ERİŞİM YOK
-- İşlem:
--   - Company için policy yoksa INSERT, varsa UPDATE (UPSERT)
-- ================================================================

DROP FUNCTION IF EXISTS security.company_password_policy_upsert(BIGINT, BIGINT, INT, INT);
DROP FUNCTION IF EXISTS security.company_password_policy_upsert(BIGINT, BIGINT, INT, INT, INT, BOOLEAN, BOOLEAN, BOOLEAN, BOOLEAN, INT, INT);

CREATE OR REPLACE FUNCTION security.company_password_policy_upsert(
    p_caller_id                BIGINT,
    p_company_id               BIGINT,
    p_expiry_days              INT     DEFAULT 30,
    p_history_count            INT     DEFAULT 3,
    p_min_length               INT     DEFAULT 8,
    p_require_uppercase        BOOLEAN DEFAULT TRUE,
    p_require_lowercase        BOOLEAN DEFAULT TRUE,
    p_require_digit            BOOLEAN DEFAULT TRUE,
    p_require_special          BOOLEAN DEFAULT FALSE,
    p_max_login_attempts       INT     DEFAULT 5,
    p_lockout_duration_minutes INT     DEFAULT 30
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
    -- 3. VALIDASYON
    -- ========================================
    IF p_expiry_days < 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.password-policy.invalid-expiry-days';
    END IF;

    IF p_history_count < 0 OR p_history_count > 10 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.password-policy.invalid-history-count';
    END IF;

    IF p_min_length NOT BETWEEN 6 AND 128 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.password-policy.invalid-min-length';
    END IF;

    IF p_max_login_attempts NOT BETWEEN 0 AND 20 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.password-policy.invalid-max-login-attempts';
    END IF;

    IF p_lockout_duration_minutes < 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.password-policy.invalid-lockout-duration';
    END IF;

    -- ========================================
    -- 4. UPSERT
    -- ========================================
    INSERT INTO security.company_password_policy (
        company_id,
        expiry_days,
        history_count,
        min_length,
        require_uppercase,
        require_lowercase,
        require_digit,
        require_special,
        max_login_attempts,
        lockout_duration_minutes,
        created_at,
        created_by,
        updated_at,
        updated_by
    )
    VALUES (
        p_company_id,
        p_expiry_days,
        p_history_count,
        p_min_length,
        p_require_uppercase,
        p_require_lowercase,
        p_require_digit,
        p_require_special,
        p_max_login_attempts,
        p_lockout_duration_minutes,
        NOW(),
        p_caller_id,
        NOW(),
        p_caller_id
    )
    ON CONFLICT (company_id) DO UPDATE
    SET expiry_days              = EXCLUDED.expiry_days,
        history_count            = EXCLUDED.history_count,
        min_length               = EXCLUDED.min_length,
        require_uppercase        = EXCLUDED.require_uppercase,
        require_lowercase        = EXCLUDED.require_lowercase,
        require_digit            = EXCLUDED.require_digit,
        require_special          = EXCLUDED.require_special,
        max_login_attempts       = EXCLUDED.max_login_attempts,
        lockout_duration_minutes = EXCLUDED.lockout_duration_minutes,
        updated_at               = NOW(),
        updated_by               = p_caller_id;
END;
$$;

COMMENT ON FUNCTION security.company_password_policy_upsert(BIGINT, BIGINT, INT, INT, INT, BOOLEAN, BOOLEAN, BOOLEAN, BOOLEAN, INT, INT) IS
'Creates or updates company password policy with IDOR protection.
Access: Platform Admin (any company), CompanyAdmin (own company only).
Parameters:
  - p_expiry_days: Password expiry in days (0 = no expiry, default 30)
  - p_history_count: Number of previous passwords to check (0-10, default 3)
  - p_min_length: Minimum password length (6-128, default 8)
  - p_require_uppercase/lowercase/digit/special: Complexity flags
  - p_max_login_attempts: Lockout threshold (0 = no lockout, default 5)
  - p_lockout_duration_minutes: Lockout duration (0 = manual unlock, default 30)';
