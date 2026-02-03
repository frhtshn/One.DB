-- ================================================================
-- PROVIDER_SETTING_LIST: Provider ayarlarını listeler
-- Sadece SuperAdmin erişebilir
-- Provider ID'ye göre filtreleme zorunlu
-- ================================================================

DROP FUNCTION IF EXISTS catalog.provider_setting_list(BIGINT);
DROP FUNCTION IF EXISTS catalog.provider_setting_list(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION catalog.provider_setting_list(
    p_caller_id BIGINT,
    p_provider_id BIGINT
)
RETURNS TABLE(
    id BIGINT,
    provider_id BIGINT,
    setting_key VARCHAR(100),
    setting_value JSONB,
    description VARCHAR(255),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
BEGIN
    -- Platform Admin kontrolü (SuperAdmin veya Admin)
    IF NOT EXISTS(
        SELECT 1 FROM security.user_roles ur
        JOIN security.roles r ON ur.role_id = r.id
        WHERE ur.user_id = p_caller_id
          AND ur.tenant_id IS NULL
          AND r.code = 'superadmin'
          AND r.status = 1
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.unauthorized';
    END IF;

    -- Provider ID kontrolü
    IF p_provider_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provider-setting.provider-required';
    END IF;

    -- Provider varlık kontrolü
    IF NOT EXISTS(SELECT 1 FROM catalog.providers p WHERE p.id = p_provider_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.provider.not-found';
    END IF;

    RETURN QUERY
    SELECT
        ps.id,
        ps.provider_id,
        ps.setting_key,
        ps.setting_value,
        ps.description,
        ps.created_at,
        ps.updated_at
    FROM catalog.provider_settings ps
    WHERE ps.provider_id = p_provider_id
    ORDER BY ps.setting_key;
END;
$$;

COMMENT ON FUNCTION catalog.provider_setting_list IS 'Lists all settings for a provider. SuperAdmin only.';
