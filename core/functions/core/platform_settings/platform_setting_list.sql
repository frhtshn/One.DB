-- ================================================================
-- PLATFORM_SETTING_LIST: Platform ayarlarını listele
-- Opsiyonel filtreler: category, environment, is_active
-- Yetki kontrolü uygulama katmanında yapılır
-- ================================================================

DROP FUNCTION IF EXISTS core.platform_setting_list(VARCHAR, VARCHAR, BOOLEAN);

CREATE OR REPLACE FUNCTION core.platform_setting_list(
    p_category VARCHAR DEFAULT NULL,       -- Filtre: EMAIL, GEO_LOCATION, EXCHANGE_RATE
    p_environment VARCHAR DEFAULT NULL,    -- Filtre: production, staging
    p_is_active BOOLEAN DEFAULT NULL       -- Filtre: aktif/pasif (NULL = hepsi)
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'id', ps.id,
                'category', ps.category,
                'settingKey', ps.setting_key,
                'settingValue', ps.setting_value,
                'environment', ps.environment,
                'isActive', ps.is_active,
                'description', ps.description,
                'createdAt', ps.created_at,
                'updatedAt', ps.updated_at
            ) ORDER BY ps.category, ps.setting_key
        )
        FROM core.platform_settings ps
        WHERE (p_category IS NULL OR ps.category = p_category)
          AND (p_environment IS NULL OR ps.environment = p_environment)
          AND (p_is_active IS NULL OR ps.is_active = p_is_active)
    ), '[]'::jsonb);
END;
$$;

COMMENT ON FUNCTION core.platform_setting_list(VARCHAR, VARCHAR, BOOLEAN) IS 'Lists platform service configurations with optional filters.';
