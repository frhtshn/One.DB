-- ================================================================
-- USER_UPDATE: Kullanıcı güncelle (IDOR Korumalı)
-- ================================================================
-- Erişim Kuralları:
--   - Kendisi: Her zaman güncelleyebilir
--   - Platform Admin: Herkesi güncelleyebilir
--   - CompanyAdmin: Kendi şirketinde, hiyerarşi (caller_level > target_level)
--   - TenantAdmin: Kendi tenant'ında, hiyerarşi
--   - Diğerleri: ERİŞİM YOK
-- Güvenlik:
--   - Kilitli caller erişemez
--   - Silinmiş hedef güncellenemez
-- p_department_id verilirse primary departman değiştirilir
-- ================================================================

DROP FUNCTION IF EXISTS security.user_update(BIGINT, BIGINT, TEXT, TEXT, TEXT, TEXT, SMALLINT, CHAR(2), VARCHAR(50), CHAR(3), BOOLEAN, BOOLEAN, BIGINT);

CREATE OR REPLACE FUNCTION security.user_update(
    p_caller_id BIGINT,
    p_user_id BIGINT,
    p_first_name TEXT DEFAULT NULL,
    p_last_name TEXT DEFAULT NULL,
    p_email TEXT DEFAULT NULL,
    p_username TEXT DEFAULT NULL,
    p_status SMALLINT DEFAULT NULL,
    p_language CHAR(2) DEFAULT NULL,
    p_timezone VARCHAR(50) DEFAULT NULL,
    p_currency CHAR(3) DEFAULT NULL,
    p_two_factor_enabled BOOLEAN DEFAULT NULL,
    p_require_password_change BOOLEAN DEFAULT NULL,
    p_department_id BIGINT DEFAULT NULL           -- Primary departmanı değiştir
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = security, core, pg_temp
AS $$
DECLARE
    v_caller_company_id BIGINT;
    v_caller_level INT;
    v_caller_has_platform_role BOOLEAN;
    v_caller_is_company_admin BOOLEAN;
    v_caller_tenant_ids BIGINT[];
    v_target_company_id BIGINT;
    v_target_level INT;
    v_target_status SMALLINT;
    v_target_has_role_in_caller_tenant BOOLEAN;
    v_current_email TEXT;
    v_current_username TEXT;
BEGIN
    -- ========================================
    -- 1. CALLER BİLGİLERİNİ AL
    -- ========================================
    SELECT
        u.company_id,
        COALESCE(MAX(r.level), 0),
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
    INTO v_caller_company_id, v_caller_level, v_caller_has_platform_role, v_caller_is_company_admin
    FROM security.users u
    LEFT JOIN security.user_roles ur ON ur.user_id = u.id AND ur.tenant_id IS NULL
    LEFT JOIN security.roles r ON r.id = ur.role_id AND r.status = 1
    WHERE u.id = p_caller_id
      AND u.status = 1
      AND u.is_locked = FALSE
      AND (u.locked_until IS NULL OR u.locked_until < NOW())
    GROUP BY u.id, u.company_id;

    IF v_caller_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.unauthorized';
    END IF;

    -- ========================================
    -- 2. TARGET BİLGİLERİNİ AL
    -- ========================================
    SELECT
        u.company_id,
        u.email,
        u.username,
        u.status,
        COALESCE(MAX(r.level), 0)
    INTO v_target_company_id, v_current_email, v_current_username, v_target_status, v_target_level
    FROM security.users u
    LEFT JOIN security.user_roles ur ON ur.user_id = u.id AND ur.tenant_id IS NULL
    LEFT JOIN security.roles r ON r.id = ur.role_id AND r.status = 1
    WHERE u.id = p_user_id
    GROUP BY u.id, u.company_id, u.email, u.username, u.status;

    IF v_target_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
    END IF;

    -- Silinmiş kullanıcı güncellenemez
    IF v_target_status = -1 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.user.update.is-deleted';
    END IF;

    -- ========================================
    -- 3. IDOR KONTROLÜ
    -- ========================================
    -- Kendisi değilse kontrol yap
    IF p_caller_id != p_user_id THEN
        -- Platform admin değilse
        IF NOT v_caller_has_platform_role THEN
            -- Company scope kontrolü
            IF v_target_company_id != v_caller_company_id THEN
                RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.company-scope-denied';
            END IF;

            -- Hiyerarşi kontrolü: Caller level > Target level
            IF v_caller_level <= v_target_level THEN
                RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.hierarchy-violation';
            END IF;

            -- CompanyAdmin değilse TenantAdmin kontrolü
            IF NOT v_caller_is_company_admin THEN
                -- TenantAdmin olduğu tenant'ları al (aktif roller)
                SELECT ARRAY_AGG(DISTINCT ur.tenant_id)
                INTO v_caller_tenant_ids
                FROM security.user_roles ur
                JOIN security.roles r ON ur.role_id = r.id AND r.status = 1
                WHERE ur.user_id = p_caller_id
                  AND ur.tenant_id IS NOT NULL
                  AND r.code = 'tenantadmin';

                -- TenantAdmin değilse (tenant_ids NULL) erişemez
                IF v_caller_tenant_ids IS NULL THEN
                    RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.denied';
                END IF;

                -- TenantAdmin scope kontrolü (aktif roller)
                SELECT EXISTS(
                    SELECT 1 FROM security.user_roles ur
                    JOIN security.roles r ON ur.role_id = r.id AND r.status = 1
                    WHERE ur.user_id = p_user_id
                      AND ur.tenant_id = ANY(v_caller_tenant_ids)
                ) INTO v_target_has_role_in_caller_tenant;

                IF NOT v_target_has_role_in_caller_tenant THEN
                    RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.tenant-scope-denied';
                END IF;
            END IF;
        END IF;
    END IF;

    -- ========================================
    -- 4. UNIQUE KONTROLLER
    -- ========================================
    -- Email benzersizlik kontrolü (değişiyorsa)
    IF p_email IS NOT NULL AND LOWER(TRIM(p_email)) != v_current_email THEN
        IF EXISTS (SELECT 1 FROM security.users WHERE email = LOWER(TRIM(p_email)) AND id != p_user_id) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.user.update.email-exists';
        END IF;
    END IF;

    -- Username benzersizlik kontrolü (değişiyorsa, aynı company içinde)
    IF p_username IS NOT NULL AND LOWER(TRIM(p_username)) != v_current_username THEN
        IF EXISTS (
            SELECT 1 FROM security.users
            WHERE company_id = v_target_company_id
              AND username = LOWER(TRIM(p_username))
              AND id != p_user_id
        ) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.user.update.username-exists';
        END IF;
    END IF;

    -- Departman varlık kontrolü (değiştiriliyorsa)
    IF p_department_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM core.departments
            WHERE id = p_department_id AND company_id = v_target_company_id AND is_active = TRUE
        ) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.department.not-found';
        END IF;
    END IF;

    -- ========================================
    -- 5. GÜNCELLEME
    -- ========================================
    UPDATE security.users
    SET first_name = COALESCE(TRIM(p_first_name), first_name),
        last_name = COALESCE(TRIM(p_last_name), last_name),
        email = COALESCE(LOWER(TRIM(p_email)), email),
        username = COALESCE(LOWER(TRIM(p_username)), username),
        status = COALESCE(p_status, status),
        language = COALESCE(p_language, language),
        timezone = COALESCE(p_timezone, timezone),
        currency = COALESCE(p_currency, currency),
        two_factor_enabled = COALESCE(p_two_factor_enabled, two_factor_enabled),
        require_password_change = COALESCE(p_require_password_change, require_password_change),
        updated_at = NOW(),
        updated_by = p_caller_id
    WHERE id = p_user_id;

    -- Race condition kontrolü
    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.concurrent-modification';
    END IF;

    -- ========================================
    -- 6. DEPARTMAN ATAMASI
    -- ========================================
    IF p_department_id IS NOT NULL THEN
        -- Mevcut primary'yi kaldır
        UPDATE core.user_departments
        SET is_primary = FALSE
        WHERE user_id = p_user_id AND is_primary = TRUE;

        -- Yeni departmanı ata veya güncelle
        INSERT INTO core.user_departments (user_id, department_id, is_primary, assigned_by)
        VALUES (p_user_id, p_department_id, TRUE, p_caller_id)
        ON CONFLICT (user_id, department_id) DO UPDATE
        SET is_primary = TRUE;
    END IF;
END;
$$;

COMMENT ON FUNCTION security.user_update(BIGINT, BIGINT, TEXT, TEXT, TEXT, TEXT, SMALLINT, CHAR(2), VARCHAR(50), CHAR(3), BOOLEAN, BOOLEAN, BIGINT) IS
'Updates user with IDOR protection.
p_department_id: optional, changes primary department (validates same company + active).
Access: Self (always), Platform Admin (all), CompanyAdmin (own company + hierarchy), TenantAdmin (own tenants + hierarchy).
Locked callers and deleted targets are rejected.
p_require_password_change: Admins can force user to change password on next login.';
