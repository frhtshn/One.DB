-- ================================================================
-- PAGE_UPDATE: Sayfa Güncelleme
-- NULL gelen alanlar güncellenmez (Partial Update).
-- ================================================================

DROP FUNCTION IF EXISTS presentation.page_update CASCADE;

CREATE OR REPLACE FUNCTION presentation.page_update(
    p_page_id BIGINT,
    p_menu_id BIGINT DEFAULT NULL,
    p_submenu_id BIGINT DEFAULT NULL,
    p_route TEXT DEFAULT NULL,
    p_title_localization_key TEXT DEFAULT NULL,
    p_required_permission TEXT DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Sayfa var mı kontrol et
    IF NOT EXISTS (SELECT 1 FROM presentation.pages WHERE id = p_page_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.page.not-found';
    END IF;

    -- Güncelleme (NULL olanlar mevcut değeri korur)
    UPDATE presentation.pages
    SET menu_id = COALESCE(p_menu_id, menu_id),
        submenu_id = COALESCE(p_submenu_id, submenu_id),
        route = COALESCE(TRIM(p_route), route),
        title_localization_key = COALESCE(TRIM(p_title_localization_key), title_localization_key),
        required_permission = CASE
            WHEN p_required_permission IS NULL THEN required_permission
            WHEN TRIM(p_required_permission) = '' THEN NULL
            ELSE TRIM(p_required_permission)
        END,
        is_active = COALESCE(p_is_active, is_active),
        updated_at = NOW()
    WHERE id = p_page_id;
END;
$$;

COMMENT ON FUNCTION presentation.page_update IS 'Updates page with partial update support. NULL values keep existing data.';
