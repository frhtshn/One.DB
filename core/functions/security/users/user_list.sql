-- ================================================================
-- USER_LIST: Kullanıcı listesi (IDOR Korumalı, CTE Optimized)
-- ================================================================
-- Erişim Kuralları:
--   - Platform Admin: Her şeyi görebilir (p_tenant_id NULL = tümü)
--   - CompanyAdmin: Sadece kendi şirketi (p_tenant_id NULL = tüm şirket)
--   - TenantAdmin: Sadece kendi tenant'ları (p_tenant_id zorunlu)
--   - Diğerleri: ERİŞİM YOK
-- Güvenlik:
--   - Kilitli caller erişemez
-- Performans:
--   - CTE ile roller tek seferde çekilir (N+1 yok)
-- ================================================================

DROP FUNCTION IF EXISTS security.user_list(BIGINT, BIGINT, BIGINT, INT, INT, TEXT, SMALLINT, TEXT, TEXT);

CREATE OR REPLACE FUNCTION security.user_list(
    p_caller_id BIGINT,
    p_company_id BIGINT,
    p_tenant_id BIGINT DEFAULT NULL,
    p_page INT DEFAULT 1,
    p_page_size INT DEFAULT 10,
    p_search TEXT DEFAULT NULL,
    p_status SMALLINT DEFAULT NULL,
    p_sort_by TEXT DEFAULT 'id',
    p_sort_order TEXT DEFAULT 'ASC'
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = security, core, pg_temp
AS $$
DECLARE
    v_caller_company_id BIGINT;
    v_caller_has_platform_role BOOLEAN;
    v_caller_is_company_admin BOOLEAN;
    v_caller_tenant_ids BIGINT[];
    v_offset INT;
    v_total_count BIGINT;
    v_items JSONB;
    v_sort_column TEXT;
    v_sort_dir TEXT;
    v_effective_company_id BIGINT;
    v_can_see_global_roles BOOLEAN;
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
    -- 2. IDOR KONTROLÜ VE SCOPE BELİRLEME
    -- ========================================
    IF v_caller_has_platform_role THEN
        v_effective_company_id := p_company_id;
        v_can_see_global_roles := TRUE;
    ELSIF v_caller_is_company_admin THEN
        IF v_caller_company_id != p_company_id THEN
            RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.company-scope-denied';
        END IF;
        v_effective_company_id := v_caller_company_id;
        v_can_see_global_roles := TRUE;
    ELSE
        IF v_caller_company_id != p_company_id THEN
            RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.company-scope-denied';
        END IF;
        v_effective_company_id := v_caller_company_id;
        v_can_see_global_roles := FALSE;

        SELECT ARRAY_AGG(DISTINCT ur.tenant_id)
        INTO v_caller_tenant_ids
        FROM security.user_roles ur
        JOIN security.roles r ON ur.role_id = r.id AND r.status = 1
        WHERE ur.user_id = p_caller_id
          AND ur.tenant_id IS NOT NULL
          AND r.code = 'tenantadmin';

        IF v_caller_tenant_ids IS NULL THEN
            RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.denied';
        END IF;

        IF p_tenant_id IS NULL THEN
            RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.field.missing';
        END IF;

        IF NOT (p_tenant_id = ANY(v_caller_tenant_ids)) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.tenant-scope-denied';
        END IF;
    END IF;

    -- ========================================
    -- 3. PAGINATION VE SIRALAMA
    -- ========================================
    v_offset := (p_page - 1) * p_page_size;

    v_sort_column := CASE LOWER(COALESCE(p_sort_by, 'id'))
        WHEN 'id' THEN 'id'
        WHEN 'firstname' THEN 'first_name'
        WHEN 'lastname' THEN 'last_name'
        WHEN 'email' THEN 'email'
        WHEN 'username' THEN 'username'
        WHEN 'status' THEN 'status'
        WHEN 'createdat' THEN 'created_at'
        WHEN 'lastloginat' THEN 'last_login_at'
        ELSE 'id'
    END;

    v_sort_dir := CASE UPPER(COALESCE(p_sort_order, 'ASC'))
        WHEN 'DESC' THEN 'DESC'
        ELSE 'ASC'
    END;

    -- ========================================
    -- 4. TOTAL COUNT
    -- ========================================
    SELECT COUNT(DISTINCT u.id)
    INTO v_total_count
    FROM security.users u
    WHERE u.company_id = v_effective_company_id
      AND (p_status IS NULL OR u.status = p_status)
      AND (p_tenant_id IS NULL OR EXISTS (
          SELECT 1 FROM security.user_roles ur WHERE ur.user_id = u.id AND ur.tenant_id = p_tenant_id
      ))
      AND (p_search IS NULL OR p_search = '' OR (
          u.email ILIKE '%' || p_search || '%' OR
          u.username ILIKE '%' || p_search || '%' OR
          u.first_name ILIKE '%' || p_search || '%' OR
          u.last_name ILIKE '%' || p_search || '%'
      ));

    -- ========================================
    -- 5. CTE İLE OPTİMİZE EDİLMİŞ ITEMS
    -- ========================================
    EXECUTE format(
        'WITH filtered_users AS (
            SELECT u.id, u.company_id, u.first_name, u.last_name, u.email, u.username,
                   u.status, u.is_locked, u.two_factor_enabled, u.language, u.timezone,
                   u.currency, u.last_login_at, u.created_at
            FROM security.users u
            WHERE u.company_id = $1
              AND ($2 IS NULL OR u.status = $2)
              AND ($3 IS NULL OR EXISTS (
                  SELECT 1 FROM security.user_roles ur WHERE ur.user_id = u.id AND ur.tenant_id = $3
              ))
              AND ($4 IS NULL OR $4 = '''' OR (
                  u.email ILIKE ''%%'' || $4 || ''%%'' OR
                  u.username ILIKE ''%%'' || $4 || ''%%'' OR
                  u.first_name ILIKE ''%%'' || $4 || ''%%'' OR
                  u.last_name ILIKE ''%%'' || $4 || ''%%''
              ))
            ORDER BY %s %s
            LIMIT $5 OFFSET $6
        ),
        user_roles_agg AS (
            SELECT
                ur.user_id,
                jsonb_agg(
                    jsonb_build_object(
                        ''roleId'', r.id,
                        ''roleCode'', r.code,
                        ''roleName'', r.name
                    )
                ) FILTER (WHERE ur.tenant_id IS NULL) AS global_roles,
                jsonb_agg(
                    jsonb_build_object(
                        ''tenantId'', ur.tenant_id,
                        ''roleId'', r.id,
                        ''roleCode'', r.code,
                        ''roleName'', r.name
                    )
                ) FILTER (WHERE ur.tenant_id IS NOT NULL AND ($3 IS NULL OR ur.tenant_id = $3)) AS tenant_roles
            FROM security.user_roles ur
            JOIN security.roles r ON r.id = ur.role_id AND r.status = 1
            WHERE ur.user_id IN (SELECT id FROM filtered_users)
            GROUP BY ur.user_id
        )
        SELECT COALESCE(jsonb_agg(
            jsonb_build_object(
                ''id'', fu.id,
                ''companyId'', fu.company_id,
                ''firstName'', fu.first_name,
                ''lastName'', fu.last_name,
                ''email'', fu.email,
                ''username'', fu.username,
                ''status'', fu.status,
                ''isLocked'', fu.is_locked,
                ''twoFactorEnabled'', fu.two_factor_enabled,
                ''language'', fu.language,
                ''timezone'', fu.timezone,
                ''currency'', fu.currency,
                ''lastLoginAt'', fu.last_login_at,
                ''createdAt'', fu.created_at,
                ''roles'', CASE WHEN $7 THEN COALESCE(ura.global_roles, ''[]''::jsonb) ELSE ''[]''::jsonb END,
                ''tenantRoles'', COALESCE(ura.tenant_roles, ''[]''::jsonb)
            ) ORDER BY fu.%s %s
        ), ''[]''::jsonb)
        FROM filtered_users fu
        LEFT JOIN user_roles_agg ura ON ura.user_id = fu.id',
        v_sort_column, v_sort_dir,
        v_sort_column, v_sort_dir
    )
    INTO v_items
    USING v_effective_company_id, p_status, p_tenant_id, p_search,
          p_page_size, v_offset, v_can_see_global_roles;

    -- ========================================
    -- 6. SONUÇ
    -- ========================================
    RETURN jsonb_build_object(
        'items', v_items,
        'totalCount', v_total_count,
        'page', p_page,
        'pageSize', p_page_size,
        'totalPages', CEIL(v_total_count::DECIMAL / p_page_size)
    );
END;
$$;

COMMENT ON FUNCTION security.user_list(BIGINT, BIGINT, BIGINT, INT, INT, TEXT, SMALLINT, TEXT, TEXT) IS
'Returns paginated user list with IDOR protection (CTE optimized).
Access: Platform Admin (all), CompanyAdmin (own company), TenantAdmin (own tenants).
p_tenant_id NULL means all tenants for Platform/CompanyAdmin, required for TenantAdmin.
Locked callers are rejected. Roles fetched in single pass (no N+1).';
