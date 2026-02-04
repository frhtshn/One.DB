-- ================================================================
-- MENU_GROUP_UPDATE: Menü Grubu Güncelleme
-- NULL gelen alanlar güncellenmez (Partial Update).
-- ================================================================

DROP FUNCTION IF EXISTS presentation.menu_group_update CASCADE;

CREATE OR REPLACE FUNCTION presentation.menu_group_update(
    p_menu_group_id BIGINT,
    p_title TEXT DEFAULT NULL,
    p_order INT DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Menü grubu var mı kontrol et
    IF NOT EXISTS (SELECT 1 FROM presentation.menu_groups WHERE id = p_menu_group_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.menu-group.not-found';
    END IF;

    -- Güncelleme (NULL olanlar mevcut değeri korur)
    UPDATE presentation.menu_groups
    SET title_localization_key = COALESCE(TRIM(p_title), title_localization_key),
        order_index = COALESCE(p_order, order_index),

        is_active = COALESCE(p_is_active, is_active),
        updated_at = NOW()
    WHERE id = p_menu_group_id;
END;
$$;

COMMENT ON FUNCTION presentation.menu_group_update IS 'Updates menu group with partial update support. NULL values keep existing data.';
