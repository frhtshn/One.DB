-- ================================================================
-- PROVIDER_SETTING_UPSERT: Provider ayari ekler veya gunceller
-- Key varsa gunceller, yoksa ekler
-- ================================================================

DROP FUNCTION IF EXISTS catalog.provider_setting_upsert(BIGINT, VARCHAR, TEXT, VARCHAR);

CREATE OR REPLACE FUNCTION catalog.provider_setting_upsert(
    p_provider_id BIGINT,
    p_key VARCHAR(100),
    p_value TEXT,
    p_description VARCHAR(255) DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_key VARCHAR(100);
    v_result_id BIGINT;
BEGIN
    -- Provider ID kontrolu
    IF p_provider_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provider-setting.provider-required';
    END IF;

    -- Provider varlik kontrolu
    IF NOT EXISTS(SELECT 1 FROM catalog.providers p WHERE p.id = p_provider_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.provider.not-found';
    END IF;

    -- Key kontrolu
    IF p_key IS NULL OR LENGTH(TRIM(p_key)) < 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provider-setting.key-invalid';
    END IF;

    -- Value kontrolu
    IF p_value IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provider-setting.value-required';
    END IF;

    v_key := LOWER(TRIM(p_key));

    -- Upsert
    INSERT INTO catalog.provider_settings (provider_id, setting_key, setting_value, description, created_at, updated_at)
    VALUES (p_provider_id, v_key, p_value::jsonb, NULLIF(TRIM(p_description), ''), NOW(), NOW())
    ON CONFLICT (provider_id, setting_key) DO UPDATE
    SET setting_value = EXCLUDED.setting_value,
        description = COALESCE(EXCLUDED.description, catalog.provider_settings.description),
        updated_at = NOW()
    RETURNING id INTO v_result_id;

    RETURN v_result_id;
END;
$$;

COMMENT ON FUNCTION catalog.provider_setting_upsert IS 'Creates or updates a provider setting.';
