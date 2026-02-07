-- ================================================================
-- PLATFORM_SETTING_CREATE: Yeni platform ayarı ekle
-- Dış servis yapılandırması oluşturur (ip-api, SMTP, AWS SES vb.)
-- Yetki kontrolü uygulama katmanında yapılır
-- ================================================================

DROP FUNCTION IF EXISTS core.platform_setting_create(VARCHAR, VARCHAR, TEXT, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION core.platform_setting_create(
    p_category VARCHAR,          -- Kategori: EMAIL, GEO_LOCATION, EXCHANGE_RATE
    p_setting_key VARCHAR,       -- Ayar anahtarı: smtp, aws_ses, ip_api
    p_setting_value TEXT,        -- Şifreli ayar değeri (uygulama katmanında şifrelenmiş)
    p_environment VARCHAR DEFAULT 'production',  -- Ortam: production, staging
    p_description VARCHAR DEFAULT NULL           -- Açıklama
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_id BIGINT;
BEGIN
    -- 1. Aynı setting_key + environment benzersizlik kontrolü
    IF EXISTS (
        SELECT 1 FROM core.platform_settings
        WHERE setting_key = p_setting_key AND environment = p_environment
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.platform-settings.already-exists';
    END IF;

    -- 2. Kayıt oluştur
    INSERT INTO core.platform_settings (
        category, setting_key, setting_value,
        environment, description
    ) VALUES (
        p_category, p_setting_key, p_setting_value,
        p_environment, p_description
    )
    RETURNING id INTO v_id;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION core.platform_setting_create(VARCHAR, VARCHAR, TEXT, VARCHAR, VARCHAR) IS 'Creates a new platform service configuration.';
