-- ================================================================
-- LOCALIZATION_IMPORT: Çeviri İçe Aktarma (Bulk Import)
-- JSON formatındaki çevirileri belirtilen dile aktarır.
-- ================================================================

DROP FUNCTION IF EXISTS catalog.localization_import(CHAR(2), JSONB);

CREATE OR REPLACE FUNCTION catalog.localization_import(
    p_lang CHAR(2),
    p_translations JSONB
)
RETURNS TABLE(inserted INT, updated INT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_inserted INT := 0;
    v_updated INT := 0;
    v_key TEXT;
    v_text TEXT;
    v_key_id BIGINT;
    v_is_insert BOOLEAN;
BEGIN
    IF NOT EXISTS(SELECT 1 FROM catalog.languages WHERE language_code = p_lang) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.language.not-found';
    END IF;

    FOR v_key, v_text IN SELECT * FROM jsonb_each_text(p_translations)
    LOOP
        SELECT lk.id INTO v_key_id FROM catalog.localization_keys lk WHERE lk.localization_key = v_key;

        IF v_key_id IS NOT NULL THEN
            -- Check if this is an insert or update
            v_is_insert := NOT EXISTS(
                SELECT 1 FROM catalog.localization_values lv
                WHERE lv.localization_key_id = v_key_id AND lv.language_code = p_lang
            );

            INSERT INTO catalog.localization_values (localization_key_id, language_code, localized_text, created_at)
            VALUES (v_key_id, p_lang, v_text, NOW())
            ON CONFLICT (localization_key_id, language_code)
            DO UPDATE SET localized_text = EXCLUDED.localized_text;

            IF v_is_insert THEN
                v_inserted := v_inserted + 1;
            ELSE
                v_updated := v_updated + 1;
            END IF;
        END IF;
    END LOOP;

    RETURN QUERY SELECT v_inserted, v_updated;
END;
$$;

COMMENT ON FUNCTION catalog.localization_import(CHAR(2), JSONB) IS 'Imports translations from JSON for a specific language.';
