-- ================================================================
-- TENANT_NAVIGATION_INIT_FROM_TEMPLATE: Template'den navigasyon oluştur
-- ================================================================
-- Açıklama:
--   Seçilen navigation_template'deki tüm öğeleri tenant_navigation'a kopyalar.
--   Mevcut navigasyon varsa hata verir (force parametresi ile override edilebilir).
-- Erişim:
--   - Platform Admin: Tüm tenant'lar
--   - CompanyAdmin: Kendi company'sindeki tenant'lar
--   - TenantAdmin: user_allowed_tenants'taki tenant'lar
-- ================================================================

DROP FUNCTION IF EXISTS presentation.tenant_navigation_init_from_template(BIGINT, BIGINT, INT, BOOLEAN);

CREATE OR REPLACE FUNCTION presentation.tenant_navigation_init_from_template(
    p_caller_id BIGINT,
    p_tenant_id BIGINT,
    p_template_id INT,
    p_force BOOLEAN DEFAULT FALSE
)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = presentation, catalog, core, security, pg_temp
AS $$
DECLARE
    v_caller_company_id BIGINT;
    v_caller_level INT;
    v_has_platform_role BOOLEAN;
    v_tenant_company_id BIGINT;
    v_has_tenant_access BOOLEAN;
    v_existing_count INT;
    v_inserted_count INT := 0;
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
        )
    INTO v_caller_company_id, v_caller_level, v_has_platform_role
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
    -- 2. TENANT VARLIK KONTROLÜ
    -- ========================================
    SELECT company_id INTO v_tenant_company_id
    FROM core.tenants WHERE id = p_tenant_id AND status = 1;

    IF v_tenant_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    -- ========================================
    -- 3. IDOR KONTROLÜ
    -- ========================================
    IF NOT v_has_platform_role THEN
        IF v_caller_level >= 80 THEN
            IF v_tenant_company_id != v_caller_company_id THEN
                RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.company-scope-denied';
            END IF;
        ELSE
            SELECT EXISTS(
                SELECT 1 FROM security.user_allowed_tenants
                WHERE user_id = p_caller_id AND tenant_id = p_tenant_id
            ) INTO v_has_tenant_access;

            IF NOT v_has_tenant_access THEN
                RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.tenant-scope-denied';
            END IF;
        END IF;
    END IF;

    -- ========================================
    -- 4. TEMPLATE VARLIK KONTROLÜ
    -- ========================================
    IF NOT EXISTS (SELECT 1 FROM catalog.navigation_templates WHERE id = p_template_id AND is_active = TRUE) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.navigation-template.not-found';
    END IF;

    -- ========================================
    -- 5. MEVCUT NAVİGASYON KONTROLÜ
    -- ========================================
    SELECT COUNT(*) INTO v_existing_count
    FROM presentation.tenant_navigation
    WHERE tenant_id = p_tenant_id;

    IF v_existing_count > 0 AND NOT p_force THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.tenant-navigation.already-initialized';
    END IF;

    -- Force modunda mevcut navigasyonu sil
    IF p_force AND v_existing_count > 0 THEN
        DELETE FROM presentation.tenant_navigation WHERE tenant_id = p_tenant_id;
    END IF;

    -- ========================================
    -- 6. TEMPLATE ÖĞELERİNİ KOPYALA
    -- ========================================
    INSERT INTO presentation.tenant_navigation (
        tenant_id,
        template_item_id,
        menu_location,
        translation_key,
        custom_label,
        icon,
        target_type,
        target_url,
        target_action,
        parent_id,
        display_order,
        is_visible,
        is_locked,
        is_readonly,
        created_at,
        updated_at
    )
    SELECT
        p_tenant_id,
        nti.id,                          -- template_item_id referansı
        nti.menu_location,
        nti.translation_key,
        nti.default_label,               -- custom_label olarak default_label kopyalanır
        nti.icon,
        nti.target_type,
        nti.target_url,
        nti.target_action,
        NULL,                            -- parent_id sonra güncellenecek
        nti.display_order,
        TRUE,                            -- is_visible = true
        nti.is_locked,                   -- Template'den gelen is_locked
        nti.is_locked,                   -- is_readonly = is_locked (locked olanlar readonly da olur)
        NOW(),
        NOW()
    FROM catalog.navigation_template_items nti
    WHERE nti.template_id = p_template_id
    ORDER BY nti.display_order;

    GET DIAGNOSTICS v_inserted_count = ROW_COUNT;

    -- ========================================
    -- 7. PARENT-CHILD İLİŞKİLERİNİ GÜNCELLE
    -- ========================================
    -- Template'deki parent_id'leri tenant_navigation'daki yeni ID'lerle eşleştir
    UPDATE presentation.tenant_navigation tn
    SET parent_id = (
        SELECT tn2.id
        FROM presentation.tenant_navigation tn2
        WHERE tn2.tenant_id = p_tenant_id
          AND tn2.template_item_id = (
              SELECT nti.parent_id
              FROM catalog.navigation_template_items nti
              WHERE nti.id = tn.template_item_id
          )
    )
    WHERE tn.tenant_id = p_tenant_id
      AND tn.template_item_id IS NOT NULL
      AND EXISTS (
          SELECT 1 FROM catalog.navigation_template_items nti
          WHERE nti.id = tn.template_item_id AND nti.parent_id IS NOT NULL
      );

    RETURN v_inserted_count;
END;
$$;

COMMENT ON FUNCTION presentation.tenant_navigation_init_from_template(BIGINT, BIGINT, INT, BOOLEAN) IS
'Initializes tenant navigation from a catalog template.
Copies all template items to tenant_navigation with proper parent-child relationships.
Access: Platform Admin (all), CompanyAdmin (own company), TenantAdmin (allowed tenants).
Parameters:
  - p_force: If TRUE, deletes existing navigation and re-initializes. Default FALSE.
Returns: Number of navigation items created.';
