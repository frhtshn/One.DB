-- ================================================================
-- PROVIDER_SETTING_GET: Tekil provider ayarı getirir
-- Sadece SuperAdmin erişebilir
-- provider_id + key ile arama
-- ================================================================

DROP FUNCTION IF EXISTS catalog.provider_setting_get(BIGINT);
DROP FUNCTION IF EXISTS catalog.provider_setting_get(BIGINT, VARCHAR);
DROP FUNCTION IF EXISTS catalog.provider_setting_get(BIGINT, BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION catalog.provider_setting_get(
    p_caller_id BIGINT,
    p_provider_id BIGINT,
    p_key VARCHAR(100)
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

    -- Key kontrolü
    IF p_key IS NULL OR LENGTH(TRIM(p_key)) = 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provider-setting.key-required';
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
      AND ps.setting_key = LOWER(TRIM(p_key));

    -- Bulunamadı kontrolü
    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.provider-setting.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION catalog.provider_setting_get IS 'Gets a provider setting by key. SuperAdmin only.';
