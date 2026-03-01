-- =============================================
-- 12. USER_ROLE_REMOVE: Kullanicidan rol kaldir (unified)
-- p_client_id = NULL: Global rol
-- p_client_id = değer: Client-specific rol
-- Returns: TABLE(removed) - silme bilgisi
-- =============================================

DROP FUNCTION IF EXISTS security.user_role_remove(BIGINT, BIGINT, VARCHAR, BIGINT);

CREATE OR REPLACE FUNCTION security.user_role_remove(
    p_caller_id BIGINT,
    p_user_id BIGINT,
    p_role_code VARCHAR,
    p_client_id BIGINT DEFAULT NULL
)
RETURNS TABLE(removed BOOLEAN)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_role_id BIGINT;
    v_role_level INT;
    v_deleted_count INT;
    v_caller_level INT;
    v_target_level INT;
    v_caller_company_id BIGINT;
    v_target_company_id BIGINT;
    v_has_platform_role BOOLEAN;
BEGIN
    -- 1. Caller bilgilerini al (global + hedef client rolleri dikkate alınır)
    SELECT
        u.company_id,
        COALESCE(MAX(r.level), 0),
        EXISTS(
            SELECT 1 FROM security.user_roles ur2
            JOIN security.roles r2 ON ur2.role_id = r2.id
            WHERE ur2.user_id = u.id AND ur2.client_id IS NULL AND r2.is_platform_role = TRUE
        )
    INTO v_caller_company_id, v_caller_level, v_has_platform_role
    FROM security.users u
    LEFT JOIN security.user_roles ur ON ur.user_id = u.id
        AND (ur.client_id IS NULL OR ur.client_id = p_client_id)
    LEFT JOIN security.roles r ON r.id = ur.role_id AND r.status = 1
    WHERE u.id = p_caller_id AND u.status = 1
    GROUP BY u.id, u.company_id;

    IF v_caller_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.unauthorized';
    END IF;

    -- 2. Target user kontrolü
    SELECT
        u.company_id,
        COALESCE(MAX(r.level), 0)
    INTO v_target_company_id, v_target_level
    FROM security.users u
    LEFT JOIN security.user_roles ur ON ur.user_id = u.id AND ur.client_id IS NULL
    LEFT JOIN security.roles r ON r.id = ur.role_id AND r.status = 1
    WHERE u.id = p_user_id AND u.status = 1
    GROUP BY u.id, u.company_id;

    IF v_target_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
    END IF;

    -- 3. Get role id and level
    SELECT id, level INTO v_role_id, v_role_level
    FROM security.roles
    WHERE code = LOWER(p_role_code);

    IF v_role_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.role.not-found';
    END IF;

    -- 4. Hiyerarşi kontrolü: Caller kendi seviyesinden düşük rolleri kaldırabilir
    IF v_role_level >= v_caller_level THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.role.hierarchy-violation';
    END IF;

    -- 5. Hedef kullanıcı scope kontrolü (platform rolü yoksa)
    IF NOT v_has_platform_role THEN
        IF v_target_company_id != v_caller_company_id THEN
            RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.company-scope-denied';
        END IF;

        IF v_target_level >= v_caller_level THEN
            RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.role.target-level-violation';
        END IF;
    END IF;

    -- 6. Remove
    DELETE FROM security.user_roles
    WHERE user_id = p_user_id
      AND role_id = v_role_id
      AND ((p_client_id IS NULL AND client_id IS NULL) OR (client_id = p_client_id));

    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;

    RETURN QUERY SELECT v_deleted_count > 0;
END;
$$;

COMMENT ON FUNCTION security.user_role_remove IS 'Removes a role from a user. client_id=NULL for global, client_id=value for client-specific. Enforces hierarchy rules.';
