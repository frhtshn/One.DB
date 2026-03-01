-- ================================================================
-- USER_PERMISSION_LIST: Kullanıcının tüm permission'larını döner
-- Hybrid Permission Formülü: Final = (Role Permissions + Granted) - Denied
-- Birleşik user_roles: client_id IS NULL = global, client_id IS NOT NULL = client
-- ================================================================

DROP FUNCTION IF EXISTS security.user_permission_list(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION security.user_permission_list(
    p_user_id BIGINT,
    p_client_id BIGINT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
    v_global_roles TEXT[];
    v_client_roles JSONB;
    v_role_permissions TEXT[];
    v_granted_overrides TEXT[];
    v_denied_overrides TEXT[];
    v_final_permissions TEXT[];
    v_user_record RECORD;
    v_accessible_client_ids BIGINT[];
    v_has_platform_role BOOLEAN := FALSE;
BEGIN
    -- Kullanıcı bilgilerini al
    SELECT id, company_id
    INTO v_user_record
    FROM security.users
    WHERE id = p_user_id AND status = 1;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
    END IF;

    -- Global rolleri al (client_id IS NULL)
    SELECT ARRAY_AGG(DISTINCT r.code)
    INTO v_global_roles
    FROM security.user_roles ur
    JOIN security.roles r ON ur.role_id = r.id AND r.status = 1
    WHERE ur.user_id = p_user_id AND ur.client_id IS NULL;

    -- Platform role kontrolü: Global rollerden herhangi birinin is_platform_role = true olup olmadığı
    SELECT EXISTS (
        SELECT 1
        FROM security.user_roles ur
        JOIN security.roles r ON ur.role_id = r.id AND r.status = 1
        WHERE ur.user_id = p_user_id AND ur.client_id IS NULL AND r.is_platform_role = TRUE
    )
    INTO v_has_platform_role;

    -- Client bazlı rolleri ve accessible client ID'lerini tek sorguda al (client_id IS NOT NULL)
    -- En yüksek rol seviyesine göre sıralı (ilk client = en yetkili client)
    WITH client_role_data AS (
        SELECT
            ur.client_id,
            ARRAY_AGG(DISTINCT r.code) as roles,
            MAX(r.level) as max_level
        FROM security.user_roles ur
        JOIN security.roles r ON ur.role_id = r.id AND r.status = 1
        WHERE ur.user_id = p_user_id AND ur.client_id IS NOT NULL
        GROUP BY ur.client_id
    )
    SELECT
        COALESCE(jsonb_object_agg(client_id::text, to_jsonb(roles)), '{}'::jsonb),
        COALESCE(ARRAY_AGG(client_id ORDER BY max_level DESC), '{}')
    INTO v_client_roles, v_accessible_client_ids
    FROM client_role_data;

    -- CompanyAdmin: company'sine ait tüm client'lara erişir (user_get_access_level pattern'i)
    -- Sıralı listeye sadece eksik olanları sona ekle (APPEND, sıralamayı korur)
    IF NOT v_has_platform_role AND v_global_roles IS NOT NULL AND 'companyadmin' = ANY(v_global_roles) THEN
        v_accessible_client_ids := COALESCE(v_accessible_client_ids, '{}') || ARRAY(
            SELECT t.id FROM core.clients t
            WHERE t.company_id = v_user_record.company_id AND t.status = 1
              AND t.id != ALL(COALESCE(v_accessible_client_ids, '{}'))
        );
    -- Diğer non-platform roller: user_allowed_clients'ı da dahil et
    ELSIF NOT v_has_platform_role THEN
        v_accessible_client_ids := COALESCE(v_accessible_client_ids, '{}') || ARRAY(
            SELECT uat.client_id FROM security.user_allowed_clients uat
            WHERE uat.user_id = p_user_id
              AND uat.client_id != ALL(COALESCE(v_accessible_client_ids, '{}'))
        );
    END IF;

    -- Role-based permission'ları al (global roller + belirtilen client rolleri)
    SELECT ARRAY_AGG(DISTINCT p.code)
    INTO v_role_permissions
    FROM security.permissions p
    WHERE p.status = 1
    AND p.id IN (
        -- Global rollerden gelen permission'lar (client_id IS NULL)
        SELECT rp.permission_id
        FROM security.role_permissions rp
        JOIN security.user_roles ur ON rp.role_id = ur.role_id
        JOIN security.roles r ON ur.role_id = r.id AND r.status = 1
        WHERE ur.user_id = p_user_id AND ur.client_id IS NULL

        UNION

        -- Client rollerinden gelen permission'lar (belirli client veya tümü)
        SELECT rp.permission_id
        FROM security.role_permissions rp
        JOIN security.user_roles ur ON rp.role_id = ur.role_id
        JOIN security.roles r ON ur.role_id = r.id AND r.status = 1
        WHERE ur.user_id = p_user_id
          AND ur.client_id IS NOT NULL
          AND (p_client_id IS NULL OR ur.client_id = p_client_id)
    );

    -- User-level GRANTED overrides (is_granted=true, sadece global — context-scoped dahil edilmez)
    SELECT ARRAY_AGG(DISTINCT p.code)
    INTO v_granted_overrides
    FROM security.user_permission_overrides up
    JOIN security.permissions p ON up.permission_id = p.id AND p.status = 1
    WHERE up.user_id = p_user_id
        AND up.is_granted = TRUE
        AND up.context_id IS NULL
        AND (up.client_id IS NULL OR up.client_id = p_client_id OR p_client_id IS NULL)
        AND (up.expires_at IS NULL OR up.expires_at > NOW());

    -- User-level DENIED overrides (is_granted=false, sadece global — context-scoped dahil edilmez)
    SELECT ARRAY_AGG(DISTINCT p.code)
    INTO v_denied_overrides
    FROM security.user_permission_overrides up
    JOIN security.permissions p ON up.permission_id = p.id AND p.status = 1
    WHERE up.user_id = p_user_id
        AND up.is_granted = FALSE
        AND up.context_id IS NULL
        AND (up.client_id IS NULL OR up.client_id = p_client_id OR p_client_id IS NULL)
        AND (up.expires_at IS NULL OR up.expires_at > NOW());

    -- Final permissions = (Role Permissions + Granted) - Denied
    SELECT ARRAY_AGG(DISTINCT perm)
    INTO v_final_permissions
    FROM (
        -- Role permissions
        SELECT unnest(COALESCE(v_role_permissions, '{}')) AS perm
        UNION
        -- Granted overrides
        SELECT unnest(COALESCE(v_granted_overrides, '{}'))
    ) all_perms
    WHERE perm NOT IN (SELECT unnest(COALESCE(v_denied_overrides, '{}')));

    -- Sonucu hazırla
    v_result := jsonb_build_object(
        'userId', p_user_id,
        'companyId', v_user_record.company_id,
        'globalRoles', COALESCE(to_jsonb(v_global_roles), '[]'::jsonb),
        'clientRoles', v_client_roles,
        'permissions', COALESCE(to_jsonb(v_final_permissions), '[]'::jsonb),
        'grantedOverrides', COALESCE(to_jsonb(v_granted_overrides), '[]'::jsonb),
        'deniedOverrides', COALESCE(to_jsonb(v_denied_overrides), '[]'::jsonb),
        'accessibleClientIds', COALESCE(to_jsonb(v_accessible_client_ids), '[]'::jsonb),
        'hasPlatformRole', v_has_platform_role
    );

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION security.user_permission_list IS 'Hybrid Permission: Returns user roles, permissions and client access info. Formula: (Role + Granted) - Denied. Uses unified user_roles table.';
