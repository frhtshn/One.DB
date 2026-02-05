-- ================================================================
-- PROVIDER_SETTING_GET: Tekil provider ayari getirir
-- provider_id + key ile arama
-- ================================================================

DROP FUNCTION IF EXISTS catalog.provider_setting_get(BIGINT);
DROP FUNCTION IF EXISTS catalog.provider_setting_get(BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION catalog.provider_setting_get(
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
    -- Provider ID kontrolu
    IF p_provider_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provider-setting.provider-required';
    END IF;

    -- Key kontrolu
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

    -- Bulunamadi kontrolu
    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.provider-setting.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION catalog.provider_setting_get IS 'Gets a provider setting by key.';
