-- =============================================
  -- 16. USER_TENANT_ROLE_LIST: Tenant-specific rol listesi
  -- Returns: JSONB array - dogrudan rol listesi
  -- =============================================

  DROP FUNCTION IF EXISTS security.user_tenant_role_list(BIGINT, BIGINT, BIGINT);

  CREATE OR REPLACE FUNCTION security.user_tenant_role_list(
      p_caller_id BIGINT,
      p_user_id BIGINT,
      p_tenant_id BIGINT
  )
  RETURNS JSONB
  LANGUAGE plpgsql
  SECURITY DEFINER
    AS $$
  DECLARE
      v_roles JSONB;
      v_has_platform_role BOOLEAN;
      v_caller_company_id BIGINT;
      v_target_company_id BIGINT;
      v_tenant_company_id BIGINT;
      v_has_access BOOLEAN;
  BEGIN
      -- 1. Caller bilgisi
      SELECT u.company_id
      FROM security.users u
      WHERE u.id = p_caller_id AND u.status = 1
      INTO v_caller_company_id;

      IF v_caller_company_id IS NULL THEN
          RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
      END IF;

      -- 2. Hedef user bilgisi (IDOR koruması)
      SELECT u.company_id
      FROM security.users u
      WHERE u.id = p_user_id AND u.status = 1
      INTO v_target_company_id;

      IF v_target_company_id IS NULL THEN
          RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
      END IF;

      -- 3. Tenant bilgisi
      SELECT company_id
      FROM core.tenants
      WHERE id = p_tenant_id
      INTO v_tenant_company_id;

      IF v_tenant_company_id IS NULL THEN
          RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
      END IF;

      -- 4. Platform rolü kontrolü
      SELECT EXISTS(
          SELECT 1 FROM security.user_roles ur
          JOIN security.roles r ON ur.role_id = r.id
          WHERE ur.user_id = p_caller_id AND r.is_platform_role = TRUE
      ) INTO v_has_platform_role;

      IF v_has_platform_role THEN
          -- Platform rolü varsa tüm kontrolleri atla
          NULL;
      ELSE
          -- 5. Hedef user aynı şirketten olmalı (IDOR koruması)
          IF v_target_company_id != v_caller_company_id THEN
              RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.user.not-found';
          END IF;

          -- 6. Tenant erişim kontrolü
          IF v_tenant_company_id = v_caller_company_id THEN
              -- Tenant-specific companyadmin kontrolü
              IF EXISTS (
                  SELECT 1 FROM security.user_roles ur
                  JOIN security.roles r ON ur.role_id = r.id
                  WHERE ur.user_id = p_caller_id
                    AND r.code = 'companyadmin'
              ) THEN
                  NULL;
              ELSE
                  -- user_allowed_tenants kontrolü
                  SELECT EXISTS(
                      SELECT 1 FROM security.user_allowed_tenants
                      WHERE user_id = p_caller_id AND tenant_id = p_tenant_id
                  ) INTO v_has_access;

                  IF NOT v_has_access THEN
                      RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.tenant-scope-denied';
                  END IF;
              END IF;
          ELSE
              -- Tenant başka şirkete ait
              RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.company-scope-denied';
          END IF;
      END IF;

      -- 7. Rolleri getir
      SELECT COALESCE(jsonb_agg(jsonb_build_object(
          'code', r.code,
          'name', r.name,
          'assignedAt', utr.assigned_at,
          'assignedBy', utr.assigned_by
      )), '[]'::jsonb)
      INTO v_roles
      FROM security.user_tenant_roles utr
      JOIN security.roles r ON r.id = utr.role_id
      WHERE utr.user_id = p_user_id
        AND utr.tenant_id = p_tenant_id
        AND r.status = 1;

      RETURN v_roles;
    END;
    $$;

  COMMENT ON FUNCTION security.user_tenant_role_list(BIGINT, BIGINT, BIGINT) IS
  'Lists tenant-specific roles for a user. Returns direct JSON array.
  Validates: 1) Caller exists, 2) Target user exists and same company (unless platform admin),
  3) Caller has tenant access via companyadmin role or user_allowed_tenants.';
