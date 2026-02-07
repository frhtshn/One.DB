-- ================================================================
-- PLATFORM_SETTING_UPDATE: Platform ayarını güncelle
-- Mevcut servis yapılandırmasını günceller
-- Yetki kontrolü uygulama katmanında yapılır
-- ================================================================

DROP FUNCTION IF EXISTS core.platform_setting_update(BIGINT, VARCHAR, TEXT, BOOLEAN, VARCHAR);

CREATE OR REPLACE FUNCTION core.platform_setting_update(
    p_id BIGINT,                 -- Güncellenecek kayıt ID
    p_category VARCHAR,          -- Kategori: EMAIL, GEO_LOCATION, EXCHANGE_RATE
    p_setting_value TEXT,        -- Şifreli ayar değeri
    p_is_active BOOLEAN,         -- Aktif/pasif durumu
    p_description VARCHAR DEFAULT NULL  -- Açıklama
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- 1. Kayıt varlık kontrolü
    IF NOT EXISTS (SELECT 1 FROM core.platform_settings WHERE id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.platform-settings.not-found';
    END IF;

    -- 2. Güncelle
    UPDATE core.platform_settings
    SET
        category = p_category,
        setting_value = p_setting_value,
        is_active = p_is_active,
        description = p_description,
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION core.platform_setting_update(BIGINT, VARCHAR, TEXT, BOOLEAN, VARCHAR) IS 'Updates an existing platform service configuration.';
