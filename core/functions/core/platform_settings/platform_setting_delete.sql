-- ================================================================
-- PLATFORM_SETTING_DELETE: Platform servis ayarını pasife al
-- Soft delete: is_active = false olarak işaretler
-- Yetki kontrolü uygulama katmanında yapılır
-- ================================================================

DROP FUNCTION IF EXISTS core.platform_setting_delete(BIGINT);

CREATE OR REPLACE FUNCTION core.platform_setting_delete(
    p_id BIGINT  -- Silinecek kayıt ID
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- 1. Kayıt varlık kontrolü
    IF NOT EXISTS (SELECT 1 FROM core.platform_settings WHERE id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.platform-settings.not-found';
    END IF;

    -- 2. Zaten pasif mi kontrolü
    IF EXISTS (SELECT 1 FROM core.platform_settings WHERE id = p_id AND is_active = FALSE) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.platform-settings.already-deleted';
    END IF;

    -- 3. Soft delete
    UPDATE core.platform_settings
    SET is_active = FALSE, updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION core.platform_setting_delete(BIGINT) IS 'Soft deletes a platform service configuration by setting is_active to false.';
