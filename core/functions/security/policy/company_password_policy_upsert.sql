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
DECLARE
    v_caller_company_id BIGINT;
    v_caller_has_platform_role BOOLEAN;
    v_caller_is_company_admin BOOLEAN;
BEGIN
    -- ========================================
    -- 1. CALLER BİLGİLERİNİ AL
    -- ========================================
    SELECT
        u.company_id,
        EXISTS(
            SELECT 1 FROM security.user_roles ur2
            JOIN security.roles r2 ON ur2.role_id = r2.id AND r2.status = 1
            WHERE ur2.user_id = u.id AND ur2.tenant_id IS NULL AND r2.is_platform_role = TRUE
        ),
        EXISTS(
            SELECT 1 FROM security.user_roles ur2
            JOIN security.roles r2 ON ur2.role_id = r2.id AND r2.status = 1
            WHERE ur2.user_id = u.id AND ur2.tenant_id IS NULL AND r2.code = 'companyadmin'
        )
    INTO v_caller_company_id, v_caller_has_platform_role, v_caller_is_company_admin
    FROM security.users u
    WHERE u.id = p_caller_id
      AND u.status = 1
      AND u.is_locked = FALSE
      AND (u.locked_until IS NULL OR u.locked_until < NOW());

    IF v_caller_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.unauthorized';
    END IF;

    -- ========================================
    -- 2. IDOR KONTROLÜ
    -- ========================================
    IF NOT v_caller_has_platform_role THEN
        -- CompanyAdmin sadece kendi company'sini düzenleyebilir
        IF NOT v_caller_is_company_admin OR v_caller_company_id != p_company_id THEN
            RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.company-scope-denied';
        END IF;
    END IF;

    -- ========================================
    -- 3. COMPANY VARLIK KONTROLÜ
    -- ========================================
    IF NOT EXISTS (SELECT 1 FROM core.companies WHERE id = p_company_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.company.not-found';
    END IF;

    -- ========================================
    -- 4. VALIDASYON
    -- ========================================
    IF p_expiry_days < 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.password-policy.invalid-expiry-days';
    END IF;

    IF p_history_count < 0 OR p_history_count > 10 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.password-policy.invalid-history-count';
    END IF;

    -- ========================================
    -- 5. UPSERT
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
