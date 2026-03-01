-- ================================================================
-- TENANT_NAVIGATION_REORDER: Navigasyon öğelerini yeniden sırala
-- ================================================================
-- Açıklama:
--   Belirli bir menu_location içindeki öğelerin sıralamasını günceller.
--   Array olarak gelen ID'ler sırayla 1, 2, 3... olarak ayarlanır.
-- Erişim:
--   - Platform Admin: Tüm tenant'lar
--   - CompanyAdmin: Kendi company'sindeki tenant'lar
--   - TenantAdmin: user_allowed_tenants'taki tenant'lar
-- ================================================================

DROP FUNCTION IF EXISTS presentation.tenant_navigation_reorder(BIGINT, BIGINT, VARCHAR, BIGINT[]);

CREATE OR REPLACE FUNCTION presentation.tenant_navigation_reorder(
    p_caller_id BIGINT,
    p_tenant_id BIGINT,
    p_menu_location VARCHAR(50),
    p_item_ids BIGINT[]
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = presentation, core, security, pg_temp
AS $$
DECLARE
    v_item_id BIGINT;
    v_order INT := 0;
BEGIN
    -- 1. Tenant varlık kontrolü
    IF NOT EXISTS(SELECT 1 FROM core.tenants WHERE id = p_tenant_id AND status = 1) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    -- 2. Tenant erişim kontrolü
    PERFORM security.user_assert_access_tenant(p_caller_id, p_tenant_id);

    -- ========================================
    -- 3. ID'LERİN GEÇERLİLİĞİNİ KONTROL ET
    -- ========================================
    IF EXISTS (
        SELECT 1 FROM UNNEST(p_item_ids) AS item_id
        WHERE NOT EXISTS (
            SELECT 1 FROM presentation.tenant_navigation
            WHERE id = item_id
              AND tenant_id = p_tenant_id
              AND menu_location = p_menu_location
        )
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.tenant-navigation.invalid-item-ids';
    END IF;

    -- ========================================
    -- 5. SIRALAMA GÜNCELLE
    -- ========================================
    FOREACH v_item_id IN ARRAY p_item_ids
    LOOP
        v_order := v_order + 1;
        UPDATE presentation.tenant_navigation
        SET display_order = v_order,
            updated_at = NOW()
        WHERE id = v_item_id
          AND tenant_id = p_tenant_id;
    END LOOP;
END;
$$;

COMMENT ON FUNCTION presentation.tenant_navigation_reorder(BIGINT, BIGINT, VARCHAR, BIGINT[]) IS
'Reorders navigation items within a menu_location.
Items are ordered 1, 2, 3... based on their position in the p_item_ids array.
Access: Platform Admin (all), CompanyAdmin (own company), TenantAdmin (allowed tenants).';
