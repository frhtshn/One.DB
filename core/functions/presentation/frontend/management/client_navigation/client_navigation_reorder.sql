-- ================================================================
-- CLIENT_NAVIGATION_REORDER: Navigasyon öğelerini yeniden sırala
-- ================================================================
-- Açıklama:
--   Belirli bir menu_location içindeki öğelerin sıralamasını günceller.
--   Array olarak gelen ID'ler sırayla 1, 2, 3... olarak ayarlanır.
-- Erişim:
--   - Platform Admin: Tüm client'lar
--   - CompanyAdmin: Kendi company'sindeki client'lar
--   - ClientAdmin: user_allowed_clients'taki client'lar
-- ================================================================

DROP FUNCTION IF EXISTS presentation.client_navigation_reorder(BIGINT, BIGINT, VARCHAR, BIGINT[]);

CREATE OR REPLACE FUNCTION presentation.client_navigation_reorder(
    p_caller_id BIGINT,
    p_client_id BIGINT,
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
    -- 1. Client varlık kontrolü
    IF NOT EXISTS(SELECT 1 FROM core.clients WHERE id = p_client_id AND status = 1) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.client.not-found';
    END IF;

    -- 2. Client erişim kontrolü
    PERFORM security.user_assert_access_client(p_caller_id, p_client_id);

    -- ========================================
    -- 3. ID'LERİN GEÇERLİLİĞİNİ KONTROL ET
    -- ========================================
    IF EXISTS (
        SELECT 1 FROM UNNEST(p_item_ids) AS item_id
        WHERE NOT EXISTS (
            SELECT 1 FROM presentation.client_navigation
            WHERE id = item_id
              AND client_id = p_client_id
              AND menu_location = p_menu_location
        )
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.client-navigation.invalid-item-ids';
    END IF;

    -- ========================================
    -- 5. SIRALAMA GÜNCELLE
    -- ========================================
    FOREACH v_item_id IN ARRAY p_item_ids
    LOOP
        v_order := v_order + 1;
        UPDATE presentation.client_navigation
        SET display_order = v_order,
            updated_at = NOW()
        WHERE id = v_item_id
          AND client_id = p_client_id;
    END LOOP;
END;
$$;

COMMENT ON FUNCTION presentation.client_navigation_reorder(BIGINT, BIGINT, VARCHAR, BIGINT[]) IS
'Reorders navigation items within a menu_location.
Items are ordered 1, 2, 3... based on their position in the p_item_ids array.
Access: Platform Admin (all), CompanyAdmin (own company), ClientAdmin (allowed clients).';
