-- ================================================================
-- CLIENT_NAVIGATION_INIT_FROM_TEMPLATE: Template'den navigasyon oluştur
-- ================================================================
-- Açıklama:
--   Seçilen navigation_template'deki tüm öğeleri client_navigation'a kopyalar.
--   Mevcut navigasyon varsa hata verir (force parametresi ile override edilebilir).
-- Erişim:
--   - Platform Admin: Tüm client'lar
--   - CompanyAdmin: Kendi company'sindeki client'lar
--   - ClientAdmin: user_allowed_clients'taki client'lar
-- ================================================================

DROP FUNCTION IF EXISTS presentation.client_navigation_init_from_template(BIGINT, BIGINT, INT, BOOLEAN);

CREATE OR REPLACE FUNCTION presentation.client_navigation_init_from_template(
    p_caller_id BIGINT,
    p_client_id BIGINT,
    p_template_id INT,
    p_force BOOLEAN DEFAULT FALSE
)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = presentation, catalog, core, security, pg_temp
AS $$
DECLARE
    v_existing_count INT;
    v_inserted_count INT := 0;
BEGIN
    -- 1. Client varlık kontrolü
    IF NOT EXISTS(SELECT 1 FROM core.clients WHERE id = p_client_id AND status = 1) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.client.not-found';
    END IF;

    -- 2. Client erişim kontrolü
    PERFORM security.user_assert_access_client(p_caller_id, p_client_id);

    -- ========================================
    -- 3. TEMPLATE VARLIK KONTROLÜ
    -- ========================================
    IF NOT EXISTS (SELECT 1 FROM catalog.navigation_templates WHERE id = p_template_id AND is_active = TRUE) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.navigation-template.not-found';
    END IF;

    -- ========================================
    -- 5. MEVCUT NAVİGASYON KONTROLÜ
    -- ========================================
    SELECT COUNT(*) INTO v_existing_count
    FROM presentation.client_navigation
    WHERE client_id = p_client_id;

    IF v_existing_count > 0 AND NOT p_force THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.client-navigation.already-initialized';
    END IF;

    -- Force modunda mevcut navigasyonu sil
    IF p_force AND v_existing_count > 0 THEN
        DELETE FROM presentation.client_navigation WHERE client_id = p_client_id;
    END IF;

    -- ========================================
    -- 6. TEMPLATE ÖĞELERİNİ KOPYALA
    -- ========================================
    INSERT INTO presentation.client_navigation (
        client_id,
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
        p_client_id,
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
    -- Template'deki parent_id'leri client_navigation'daki yeni ID'lerle eşleştir
    UPDATE presentation.client_navigation tn
    SET parent_id = (
        SELECT tn2.id
        FROM presentation.client_navigation tn2
        WHERE tn2.client_id = p_client_id
          AND tn2.template_item_id = (
              SELECT nti.parent_id
              FROM catalog.navigation_template_items nti
              WHERE nti.id = tn.template_item_id
          )
    )
    WHERE tn.client_id = p_client_id
      AND tn.template_item_id IS NOT NULL
      AND EXISTS (
          SELECT 1 FROM catalog.navigation_template_items nti
          WHERE nti.id = tn.template_item_id AND nti.parent_id IS NOT NULL
      );

    RETURN v_inserted_count;
END;
$$;

COMMENT ON FUNCTION presentation.client_navigation_init_from_template(BIGINT, BIGINT, INT, BOOLEAN) IS
'Initializes client navigation from a catalog template.
Copies all template items to client_navigation with proper parent-child relationships.
Access: Platform Admin (all), CompanyAdmin (own company), ClientAdmin (allowed clients).
Parameters:
  - p_force: If TRUE, deletes existing navigation and re-initializes. Default FALSE.
Returns: Number of navigation items created.';
