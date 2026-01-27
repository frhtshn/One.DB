-- ================================================================
-- LOCALIZATION_KEY_UPDATE: Çeviri Anahtarı Güncelleme
-- ================================================================

DROP FUNCTION IF EXISTS catalog.localization_key_update(BIGINT, VARCHAR, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION catalog.localization_key_update(
    p_id BIGINT,
    p_domain VARCHAR,
    p_category VARCHAR,
    p_description VARCHAR
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM catalog.localization_keys WHERE id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.localization.key.not-found';
    END IF;

    UPDATE catalog.localization_keys
    SET domain = COALESCE(LOWER(TRIM(p_domain)), domain),
        category = COALESCE(LOWER(TRIM(p_category)), category),
        description = COALESCE(TRIM(p_description), description)
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.localization_key_update(BIGINT, VARCHAR, VARCHAR, VARCHAR) IS 'Updates a localization key.';
