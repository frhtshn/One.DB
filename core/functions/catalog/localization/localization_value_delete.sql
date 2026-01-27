-- ================================================================
-- LOCALIZATION_VALUE_DELETE: Çeviri Değeri Silme
-- Belirtilen dil için tekil çeviriyi siler (Reset to default).
-- ================================================================

DROP FUNCTION IF EXISTS catalog.localization_value_delete(BIGINT, CHAR(2));

CREATE OR REPLACE FUNCTION catalog.localization_value_delete(
    p_key_id BIGINT,
    p_lang CHAR(2)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS(
        SELECT 1 FROM catalog.localization_values
        WHERE localization_key_id = p_key_id AND language_code = p_lang
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.localization.translation.not-found';
    END IF;

    DELETE FROM catalog.localization_values
    WHERE localization_key_id = p_key_id AND language_code = p_lang;
END;
$$;

COMMENT ON FUNCTION catalog.localization_value_delete(BIGINT, CHAR(2)) IS 'Deletes a specific localization value.';
