-- ================================================================
-- NAVIGATION_REORDER: Menü sıralamasını güncelle
-- Array index → display_order olarak günceller
-- Location ve parent seviyesinde çalışır
-- ================================================================

DROP FUNCTION IF EXISTS presentation.navigation_reorder(VARCHAR, BIGINT[], BIGINT);

CREATE OR REPLACE FUNCTION presentation.navigation_reorder(
    p_menu_location     VARCHAR(50),         -- Menü konumu
    p_item_ids          BIGINT[],            -- Yeni sıradaki ID'ler
    p_parent_id         BIGINT DEFAULT NULL  -- Üst menü (NULL = root level)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_item_id BIGINT;
    v_order INT := 0;
BEGIN
    -- Parametre doğrulama
    IF p_menu_location IS NULL OR p_menu_location = '' THEN
        RAISE EXCEPTION 'error.navigation.location-required';
    END IF;

    IF p_item_ids IS NULL OR array_length(p_item_ids, 1) IS NULL THEN
        RAISE EXCEPTION 'error.navigation.item-ids-required';
    END IF;

    -- Her öğeye sıra numarası ata
    FOREACH v_item_id IN ARRAY p_item_ids
    LOOP
        UPDATE presentation.navigation
        SET display_order = v_order,
            updated_at = NOW()
        WHERE id = v_item_id
          AND menu_location = p_menu_location
          AND (parent_id IS NOT DISTINCT FROM p_parent_id);

        v_order := v_order + 1;
    END LOOP;
END;
$$;

COMMENT ON FUNCTION presentation.navigation_reorder(VARCHAR, BIGINT[], BIGINT) IS 'Reorder navigation items within a menu location and parent level. Array index becomes display_order.';
