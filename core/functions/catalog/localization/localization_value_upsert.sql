-- ============================================================================
-- LOCALIZATION VALUE FUNCTIONS
-- ============================================================================

DROP FUNCTION IF EXISTS catalog.localization_value_upsert(BIGINT, CHAR(2), TEXT);

-- localization_value_upsert: Çeviri ekle/güncelle
CREATE OR REPLACE FUNCTION catalog.localization_value_upsert(
    p_key_id BIGINT,
    p_lang CHAR(2),
    p_text TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM catalog.localization_keys WHERE id = p_key_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.localization.key.not-found';
    END IF;

    IF NOT EXISTS(SELECT 1 FROM catalog.languages WHERE language_code = p_lang AND is_active = TRUE) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.language.not-found';
    END IF;

    INSERT INTO catalog.localization_values (localization_key_id, language_code, localized_text, created_at)
    VALUES (p_key_id, p_lang, p_text, NOW())
    ON CONFLICT (localization_key_id, language_code)
    DO UPDATE SET localized_text = EXCLUDED.localized_text;
END;
$$;

COMMENT ON FUNCTION catalog.localization_value_upsert(BIGINT, CHAR(2), TEXT) IS 'Inserts or updates a localization value (translation).';
