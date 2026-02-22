-- ================================================================
-- COMPANY_PASSWORD_POLICY_LIST: Tüm company'lerin şifre politikasını listele
-- ================================================================
-- Erişim Kuralları:
--   - Yalnızca Platform Admin (SuperAdmin / Admin)
--   - CompanyAdmin bu fonksiyona ERİŞEMEZ
-- Özellikler:
--   - Company adı/domain'e göre arama
--   - Özel politika filtresi (has_custom_policy)
--   - Sayfalanmış JSONB response
--   - Policy olmayan company'ler platform defaultlarıyla döner
-- ================================================================

DROP FUNCTION IF EXISTS security.company_password_policy_list(BIGINT, TEXT, BOOLEAN, INT, INT);

CREATE OR REPLACE FUNCTION security.company_password_policy_list(
    p_caller_id         BIGINT,
    p_search            TEXT    DEFAULT NULL,
    p_has_custom_policy BOOLEAN DEFAULT NULL,
    p_limit             INT     DEFAULT 20,
    p_offset            INT     DEFAULT 0
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = security, core, pg_temp
AS $$
DECLARE
    v_caller_level INT;
    v_total        BIGINT;
    v_items        JSONB;
BEGIN
    -- ========================================
    -- 1. YETKİ KONTROLÜ (Platform Admin only)
    -- ========================================
    SELECT r.level INTO v_caller_level
    FROM core.users u
    JOIN security.user_roles ur ON ur.user_id = u.id AND ur.is_active = TRUE
    JOIN security.roles r ON r.id = ur.role_id
    WHERE u.id = p_caller_id AND u.is_active = TRUE
    ORDER BY r.level DESC
    LIMIT 1;

    IF v_caller_level IS NULL OR v_caller_level < 90 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.forbidden';
    END IF;

    -- ========================================
    -- 2. LİSTELE (company JOIN)
    -- ========================================
    SELECT COUNT(*)
    INTO v_total
    FROM core.companies c
    LEFT JOIN security.company_password_policy cpp ON cpp.company_id = c.id
    WHERE c.is_active = TRUE
      AND (p_search IS NULL OR c.name ILIKE '%' || p_search || '%' OR c.domain ILIKE '%' || p_search || '%')
      AND (p_has_custom_policy IS NULL
           OR (p_has_custom_policy = TRUE  AND cpp.company_id IS NOT NULL)
           OR (p_has_custom_policy = FALSE AND cpp.company_id IS NULL));

    SELECT jsonb_agg(
        jsonb_build_object(
            'companyId',              c.id,
            'companyName',            c.name,
            'companyDomain',          c.domain,
            'hasCustomPolicy',        (cpp.company_id IS NOT NULL),
            'expiryDays',             COALESCE(cpp.expiry_days, 30),
            'historyCount',           COALESCE(cpp.history_count, 3),
            'minLength',              COALESCE(cpp.min_length, 8),
            'requireUppercase',       COALESCE(cpp.require_uppercase, TRUE),
            'requireLowercase',       COALESCE(cpp.require_lowercase, TRUE),
            'requireDigit',           COALESCE(cpp.require_digit, TRUE),
            'requireSpecial',         COALESCE(cpp.require_special, FALSE),
            'maxLoginAttempts',       COALESCE(cpp.max_login_attempts, 5),
            'lockoutDurationMinutes', COALESCE(cpp.lockout_duration_minutes, 30),
            'updatedAt',              cpp.updated_at,
            'updatedBy',              cpp.updated_by
        )
        ORDER BY c.name ASC
    )
    INTO v_items
    FROM core.companies c
    LEFT JOIN security.company_password_policy cpp ON cpp.company_id = c.id
    WHERE c.is_active = TRUE
      AND (p_search IS NULL OR c.name ILIKE '%' || p_search || '%' OR c.domain ILIKE '%' || p_search || '%')
      AND (p_has_custom_policy IS NULL
           OR (p_has_custom_policy = TRUE  AND cpp.company_id IS NOT NULL)
           OR (p_has_custom_policy = FALSE AND cpp.company_id IS NULL))
    LIMIT p_limit
    OFFSET p_offset;

    RETURN jsonb_build_object(
        'items',  COALESCE(v_items, '[]'::JSONB),
        'total',  v_total,
        'limit',  p_limit,
        'offset', p_offset
    );
END;
$$;

COMMENT ON FUNCTION security.company_password_policy_list(BIGINT, TEXT, BOOLEAN, INT, INT) IS
'Lists all companies with their password policies. Platform Admin only.
Parameters:
  - p_search: Filter by company name or domain (ILIKE)
  - p_has_custom_policy: TRUE = only custom policies, FALSE = only defaults, NULL = all
  - p_limit/p_offset: Pagination
Companies without custom policies are returned with platform default values.';
