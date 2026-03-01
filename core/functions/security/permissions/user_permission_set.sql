-- ================================================================
-- USER_PERMISSION_SET - Permission Grant/Deny (IDOR + Privilege Escalation korumalı)
-- ================================================================
-- Erişim:
--   Platform Admin: Herkese her permission'ı verebilir
--   Company Admin: Kendi şirketindeki user'lara, sahip olduğu permission'ları verebilir
--   Client Admin: Kendi client'ındaki user'lara, sahip olduğu permission'ları verebilir
--   Diğerleri: Veremez
-- ================================================================

DROP FUNCTION IF EXISTS security.user_permission_set(BIGINT, VARCHAR, BOOLEAN, BIGINT, VARCHAR, BIGINT, TIMESTAMPTZ);
DROP FUNCTION IF EXISTS security.user_permission_set(BIGINT, VARCHAR, BOOLEAN, BIGINT, VARCHAR, BIGINT, TIMESTAMPTZ, BIGINT);

CREATE OR REPLACE FUNCTION security.user_permission_set(
    p_user_id BIGINT,
    p_permission_code VARCHAR(100),
    p_is_granted BOOLEAN,
    p_client_id BIGINT DEFAULT NULL,
    p_reason VARCHAR(500) DEFAULT NULL,
    p_assigned_by BIGINT DEFAULT NULL,
    p_expires_at TIMESTAMPTZ DEFAULT NULL,
    p_context_id BIGINT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_permission_id BIGINT;
    v_existing_id BIGINT;
    v_caller_company_id BIGINT;
    v_target_company_id BIGINT;
    v_client_company_id BIGINT;
    v_has_platform_role BOOLEAN;
    v_is_company_admin BOOLEAN;
    v_is_client_admin BOOLEAN;
BEGIN
    -- ========================================
    -- 1. TEMEL DOĞRULAMALAR
    -- ========================================

    -- Permission code'u ID'ye çevir
    SELECT p.id INTO v_permission_id
    FROM security.permissions p
    WHERE p.code = p_permission_code AND p.status = 1;

    IF v_permission_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.permission.not-found';
    END IF;

    -- Hedef user var mı?
    SELECT u.company_id FROM security.users u
    WHERE u.id = p_user_id AND u.status = 1
    INTO v_target_company_id;

    IF v_target_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
    END IF;

    -- ========================================
    -- 2. IDOR + PRIVILEGE ESCALATION KONTROLLERI
    -- ========================================

    -- p_assigned_by null ise system grant - kontrol gerekmez
    IF p_assigned_by IS NOT NULL THEN
        -- Caller bilgisi
        SELECT u.company_id FROM security.users u
        WHERE u.id = p_assigned_by AND u.status = 1
        INTO v_caller_company_id;

        IF v_caller_company_id IS NULL THEN
            RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.unauthorized';
        END IF;

        -- Platform admin kontrolü (global roller, client_id IS NULL)
        SELECT EXISTS(
            SELECT 1 FROM security.user_roles ur
            JOIN security.roles r ON ur.role_id = r.id
            WHERE ur.user_id = p_assigned_by AND ur.client_id IS NULL AND r.is_platform_role = TRUE
        ) INTO v_has_platform_role;

        IF v_has_platform_role THEN
            -- Platform admin her şeyi yapabilir, privilege escalation kontrolü yok
            NULL;
        ELSE
            -- ========================================
            -- IDOR KONTROLÜ (Scope)
            -- ========================================

            -- Aynı şirketten mi?
            IF v_target_company_id != v_caller_company_id THEN
                RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.user-scope-denied';
            END IF;

            -- Company admin kontrolü (global rol, client_id IS NULL)
            SELECT EXISTS(
                SELECT 1 FROM security.user_roles ur
                JOIN security.roles r ON ur.role_id = r.id
                WHERE ur.user_id = p_assigned_by AND ur.client_id IS NULL AND r.code = 'companyadmin'
            ) INTO v_is_company_admin;

            IF v_is_company_admin THEN
                -- Company admin kendi şirketindeki herkese verebilir
                IF p_client_id IS NOT NULL THEN
                    -- Client şirkete ait mi?
                    SELECT t.company_id FROM core.clients t
                    WHERE t.id = p_client_id
                    INTO v_client_company_id;

                    IF v_client_company_id IS NULL OR v_client_company_id != v_caller_company_id THEN
                        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.client-scope-denied';
                    END IF;
                END IF;
            ELSE
                -- Client admin kontrolü
                IF p_client_id IS NULL THEN
                    RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.client.id-required';
                END IF;

                -- Client var mı ve şirkete ait mi?
                SELECT t.company_id FROM core.clients t
                WHERE t.id = p_client_id
                INTO v_client_company_id;

                IF v_client_company_id IS NULL THEN
                    RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.client.not-found';
                END IF;

                IF v_client_company_id != v_caller_company_id THEN
                    RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.client-scope-denied';
                END IF;

                -- Caller bu client'ta client admin mi? (birleşik user_roles, client_id = p_client_id)
                SELECT EXISTS(
                    SELECT 1 FROM security.user_roles ur
                    JOIN security.roles r ON ur.role_id = r.id
                    WHERE ur.user_id = p_assigned_by
                      AND ur.client_id = p_client_id
                      AND r.code = 'clientadmin'
                ) INTO v_is_client_admin;

                IF NOT v_is_client_admin THEN
                    RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.permission-denied';
                END IF;

                -- Hedef user bu client'a erişebiliyor mu?
                IF NOT EXISTS(
                    SELECT 1 FROM security.user_allowed_clients uat
                    WHERE uat.user_id = p_user_id AND uat.client_id = p_client_id
                ) AND NOT EXISTS(
                    SELECT 1 FROM security.user_roles ur
                    JOIN security.roles r ON ur.role_id = r.id
                    WHERE ur.user_id = p_user_id
                      AND ur.client_id IS NULL
                      AND r.code = 'companyadmin'
                      AND v_target_company_id = v_client_company_id
                ) AND NOT EXISTS(
                    SELECT 1 FROM security.user_roles ur
                    JOIN security.roles r ON ur.role_id = r.id
                    WHERE ur.user_id = p_user_id AND ur.client_id IS NULL AND r.is_platform_role = TRUE
                ) THEN
                    RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.user-scope-denied';
                END IF;
            END IF;

            -- ========================================
            -- PRIVILEGE ESCALATION KONTROLÜ
            -- ========================================

            -- Caller bu permission'a sahip mi? (override dahil)
            IF NOT security.permission_check(p_assigned_by, p_permission_code, p_client_id) THEN
                RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.auth.permission-escalation';
            END IF;
        END IF;
    END IF;

    -- ========================================
    -- 3. PERMISSION SET İŞLEMİ
    -- ========================================

    -- Mevcut override var mı? (context_id dahil — aynı user+permission+client+context combo)
    SELECT upo.id INTO v_existing_id
    FROM security.user_permission_overrides upo
    WHERE upo.user_id = p_user_id
      AND upo.permission_id = v_permission_id
      AND COALESCE(upo.client_id, -1) = COALESCE(p_client_id, -1)
      AND COALESCE(upo.context_id, -1) = COALESCE(p_context_id, -1);

    IF v_existing_id IS NOT NULL THEN
        -- Güncelle
        UPDATE security.user_permission_overrides
        SET is_granted = p_is_granted,
            reason = COALESCE(p_reason, reason),
            assigned_by = COALESCE(p_assigned_by, assigned_by),
            assigned_at = NOW(),
            expires_at = p_expires_at
        WHERE id = v_existing_id;

        RETURN jsonb_build_object(
            'action', 'updated',
            'id', v_existing_id,
            'permissionCode', p_permission_code,
            'isGranted', p_is_granted
        );
    ELSE
        -- Yeni kayıt
        INSERT INTO security.user_permission_overrides (
            user_id, permission_id, client_id, context_id, is_granted,
            reason, assigned_by, expires_at
        ) VALUES (
            p_user_id, v_permission_id, p_client_id, p_context_id, p_is_granted,
            p_reason, p_assigned_by, p_expires_at
        )
        RETURNING id INTO v_existing_id;

        RETURN jsonb_build_object(
            'action', 'created',
            'id', v_existing_id,
            'permissionCode', p_permission_code,
            'isGranted', p_is_granted
        );
    END IF;
END;
$$;

COMMENT ON FUNCTION security.user_permission_set IS
'Grants or Denies a specific permission to a user (IDOR + Privilege Escalation protected).
Access: Platform Admin (all), Company Admin (same company), Client Admin (same client).
Privilege Escalation: Caller can only grant permissions they have.';
