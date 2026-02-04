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

CREATE OR REPLACE FUNCTION security.company_password_policy_upsert(
    p_caller_id BIGINT,
    p_company_id BIGINT,
    p_expiry_days INT DEFAULT 30,
    p_history_count INT DEFAULT 3
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

    -- ========================================
    -- 4. UPSERT
    -- ========================================
    INSERT INTO security.company_password_policy (
        company_id,
        expiry_days,
        history_count,
        created_at,
        created_by,
        updated_at,
        updated_by
    )
    VALUES (
        p_company_id,
        p_expiry_days,
        p_history_count,
        NOW(),
        p_caller_id,
        NOW(),
        p_caller_id
    )
    ON CONFLICT (company_id) DO UPDATE
    SET expiry_days = EXCLUDED.expiry_days,
        history_count = EXCLUDED.history_count,
        updated_at = NOW(),
        updated_by = p_caller_id;
END;
$$;

COMMENT ON FUNCTION security.company_password_policy_upsert(BIGINT, BIGINT, INT, INT) IS
'Creates or updates company password policy with IDOR protection.
Access: Platform Admin (any company), CompanyAdmin (own company only).
Parameters:
  - p_expiry_days: Password expiry in days (0 = no expiry, default 30)
  - p_history_count: Number of previous passwords to check (0-10, default 3)';
