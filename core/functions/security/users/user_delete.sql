-- ================================================================
-- USER_DELETE: Kullanıcı sil (IDOR Korumalı, soft delete)
-- ================================================================
-- Erişim Kuralları:
--   - Kendisi: SİLEMEZ (güvenlik)
--   - Platform Admin: Herkesi silebilir
--   - CompanyAdmin: Kendi şirketinde, hiyerarşi (caller_level > target_level)
--   - ClientAdmin: Kendi client'ında, hiyerarşi
--   - Diğerleri: ERİŞİM YOK
-- Güvenlik:
--   - Kilitli caller erişemez
-- ================================================================

DROP FUNCTION IF EXISTS security.user_delete(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION security.user_delete(
    p_caller_id BIGINT,
    p_user_id BIGINT
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
    v_caller_client_ids BIGINT[];
    v_target_company_id BIGINT;
    v_target_level INT;
    v_target_status SMALLINT;
    v_target_has_role_in_caller_client BOOLEAN;
BEGIN
    -- ========================================
    -- 1. KENDİNİ SİLEMEZ
    -- ========================================
    IF p_caller_id = p_user_id THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.user.delete.self-not-allowed';
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
            WHERE ur2.user_id = u.id AND ur2.client_id IS NULL AND r2.is_platform_role = TRUE
        ),
        EXISTS(
            SELECT 1 FROM security.user_roles ur2
            JOIN security.roles r2 ON ur2.role_id = r2.id AND r2.status = 1
            WHERE ur2.user_id = u.id AND ur2.client_id IS NULL AND r2.code = 'companyadmin'
        )
    INTO v_caller_company_id, v_caller_level, v_caller_has_platform_role, v_caller_is_company_admin
    FROM security.users u
    LEFT JOIN security.user_roles ur ON ur.user_id = u.id AND ur.client_id IS NULL
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
    LEFT JOIN security.user_roles ur ON ur.user_id = u.id AND ur.client_id IS NULL
    LEFT JOIN security.roles r ON r.id = ur.role_id AND r.status = 1
    WHERE u.id = p_user_id
    GROUP BY u.id, u.company_id, u.status;

    IF v_target_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
    END IF;

    -- Zaten silinmiş mi?
    IF v_target_status = -1 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.user.delete.already-deleted';
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

        -- CompanyAdmin değilse ClientAdmin kontrolü
        IF NOT v_caller_is_company_admin THEN
            -- ClientAdmin olduğu client'ları al (aktif roller)
            SELECT ARRAY_AGG(DISTINCT ur.client_id)
            INTO v_caller_client_ids
            FROM security.user_roles ur
            JOIN security.roles r ON ur.role_id = r.id AND r.status = 1
            WHERE ur.user_id = p_caller_id
              AND ur.client_id IS NOT NULL
              AND r.code = 'clientadmin';

            -- ClientAdmin değilse (client_ids NULL) erişemez
            IF v_caller_client_ids IS NULL THEN
                RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.denied';
            END IF;

            -- ClientAdmin scope kontrolü (aktif roller)
            SELECT EXISTS(
                SELECT 1 FROM security.user_roles ur
                JOIN security.roles r ON ur.role_id = r.id AND r.status = 1
                WHERE ur.user_id = p_user_id
                  AND ur.client_id = ANY(v_caller_client_ids)
            ) INTO v_target_has_role_in_caller_client;

            IF NOT v_target_has_role_in_caller_client THEN
                RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.client-scope-denied';
            END IF;
        END IF;
    END IF;

    -- ========================================
    -- 5. SOFT DELETE
    -- ========================================
    UPDATE security.users
    SET status = -1,
        updated_at = NOW(),
        updated_by = p_caller_id
    WHERE id = p_user_id;

    -- Race condition kontrolü
    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.concurrent-modification';
    END IF;
END;
$$;

COMMENT ON FUNCTION security.user_delete(BIGINT, BIGINT) IS
'Soft deletes a user with IDOR protection.
Self-delete NOT allowed.
Access: Platform Admin (all), CompanyAdmin (own company + hierarchy), ClientAdmin (own clients + hierarchy).
Locked callers are rejected.';
