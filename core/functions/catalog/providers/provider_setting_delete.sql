-- ================================================================
-- PROVIDER_SETTING_DELETE: Provider ayari siler
-- ================================================================

DROP FUNCTION IF EXISTS catalog.provider_setting_delete(BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION catalog.provider_setting_delete(
    p_provider_id BIGINT,
    p_key VARCHAR(100)
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_key VARCHAR(100);
BEGIN
    -- Provider ID kontrolu
    IF p_provider_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provider-setting.provider-required';
    END IF;

    -- Key kontrolu
    IF p_key IS NULL OR LENGTH(TRIM(p_key)) = 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provider-setting.key-required';
    END IF;

    v_key := LOWER(TRIM(p_key));

    -- Mevcut kayit kontrolu
    IF NOT EXISTS(
        SELECT 1 FROM catalog.provider_settings ps
        WHERE ps.provider_id = p_provider_id AND ps.setting_key = v_key
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.provider-setting.not-found';
    END IF;

    -- Sil
    DELETE FROM catalog.provider_settings
    WHERE provider_id = p_provider_id AND setting_key = v_key;
END;
$$;

COMMENT ON FUNCTION catalog.provider_setting_delete IS 'Deletes a provider setting.';
