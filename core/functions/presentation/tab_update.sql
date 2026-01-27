-- ================================================================
-- TAB_UPDATE: Sekme güncelle (partial update)
-- NULL gelen alanlar güncellenmez
-- ================================================================

DROP FUNCTION IF EXISTS presentation.tab_update CASCADE;
CREATE OR REPLACE FUNCTION presentation.tab_update(
    p_tab_id BIGINT,
    p_title_localization_key TEXT DEFAULT NULL,
    p_order_index INT DEFAULT NULL,
    p_required_permission TEXT DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Sekme var mı kontrol et
    IF NOT EXISTS (SELECT 1 FROM presentation.tabs WHERE id = p_tab_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tab.not-found';
    END IF;

    -- Güncelleme (NULL olanlar mevcut değeri korur)
    UPDATE presentation.tabs
    SET title_localization_key = COALESCE(TRIM(p_title_localization_key), title_localization_key),
        order_index = COALESCE(p_order_index, order_index),
        required_permission = CASE
            WHEN p_required_permission IS NULL THEN required_permission
            WHEN TRIM(p_required_permission) = '' THEN NULL
            ELSE TRIM(p_required_permission)
        END,
        is_active = COALESCE(p_is_active, is_active),
        updated_at = NOW()
    WHERE id = p_tab_id;
END;
$$;

COMMENT ON FUNCTION presentation.tab_update IS 'Updates tab with partial update support. NULL values keep existing data.';
