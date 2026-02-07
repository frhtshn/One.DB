-- ================================================================
-- PLATFORM_SETTING_GET: Platform ayarını getir
-- ID ile servis yapılandırmasını döner
-- Yetki kontrolü uygulama katmanında yapılır
-- ================================================================

DROP FUNCTION IF EXISTS core.platform_setting_get(BIGINT);

CREATE OR REPLACE FUNCTION core.platform_setting_get(
    p_id BIGINT  -- Kayıt ID
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'id', ps.id,
        'category', ps.category,
        'settingKey', ps.setting_key,
        'settingValue', ps.setting_value,
        'environment', ps.environment,
        'isActive', ps.is_active,
        'description', ps.description,
        'createdAt', ps.created_at,
        'updatedAt', ps.updated_at
    )
    INTO v_result
    FROM core.platform_settings ps
    WHERE ps.id = p_id;

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.platform-settings.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION core.platform_setting_get(BIGINT) IS 'Returns a platform service configuration by ID.';
