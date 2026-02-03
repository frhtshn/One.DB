-- ================================================================
-- USER_UNLOCK: Kilitli kullanıcı hesabını açar (IDOR Korumalı)
-- ================================================================
-- Erişim Kuralları:
--   - Kendisi: AÇAMAZ (kilitliyse zaten giriş yapamaz)
--   - Platform Admin: Herkesi açabilir
--   - CompanyAdmin: Kendi şirketinde, hiyerarşi (caller_level > target_level)
--   - TenantAdmin: Kendi tenant'ında, hiyerarşi
--   - Diğerleri: ERİŞİM YOK
-- Güvenlik:
--   - Kilitli caller erişemez
--   - Silinmiş hedefin kilidi açılamaz
-- ================================================================

DROP FUNCTION IF EXISTS security.user_unlock(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION security.user_unlock(
    p_caller_id BIGINT,
    p_user_id BIGINT
)
RETURNS JSONB
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
BEGIN
    -- ========================================
    -- 1. KENDİ KİLİDİNİ AÇAMAZ
    -- ========================================
    IF p_caller_id = p_user_id THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.user.unlock.self-not-allowed';
    END IF;

    -- ========================================
    -- 2. CALLER BİLGİLERİNİ AL
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
    -- 3. TARGET BİLGİLERİNİ AL
    -- ========================================
    SELECT
        u.company_id,
        u.status,
        COALESCE(MAX(r.level), 0)
    INTO v_target_company_id, v_target_status, v_target_level
    FROM security.users u
    LEFT JOIN security.user_roles ur ON ur.user_id = u.id AND ur.tenant_id IS NULL
    LEFT JOIN security.roles r ON r.id = ur.role_id AND r.status = 1
    WHERE u.id = p_user_id
    GROUP BY u.id, u.company_id, u.status;

    IF v_target_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
    END IF;

    -- Silinmiş kullanıcının kilidi açılamaz
    IF v_target_status = -1 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.user.unlock.is-deleted';
    END IF;

    -- ========================================
    -- 4. IDOR KONTROLÜ
    -- ========================================
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

    -- ========================================
    -- 5. KİLİDİ AÇ
    -- ========================================
    UPDATE security.users
    SET is_locked = FALSE,
        locked_until = NULL,
        failed_login_count = 0,
        updated_at = NOW(),
        updated_by = p_caller_id
    WHERE id = p_user_id;

    -- Race condition kontrolü
    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.concurrent-modification';
    END IF;

    RETURN jsonb_build_object(
        'userId', p_user_id,
        'unlockedBy', p_caller_id,
        'unlockedAt', NOW()
    );
END;
$$;

COMMENT ON FUNCTION security.user_unlock(BIGINT, BIGINT) IS
'Unlocks a locked user account with IDOR protection.
Self-unlock NOT allowed.
Access: Platform Admin (all), CompanyAdmin (own company + hierarchy), TenantAdmin (own tenants + hierarchy).
Locked callers and deleted targets are rejected.';
