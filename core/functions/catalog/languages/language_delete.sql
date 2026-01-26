DROP FUNCTION IF EXISTS catalog.language_delete(CHAR(2));

-- Dili siler (soft delete - is_active = false)
CREATE OR REPLACE FUNCTION catalog.language_delete(p_code CHAR(2))
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_code CHAR(2);
    v_translation_count INT;
BEGIN
    v_code := LOWER(TRIM(p_code));

    -- Mevcut mu kontrolu
    IF NOT EXISTS(SELECT 1 FROM catalog.languages l WHERE l.language_code = v_code) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.language.not-found';
    END IF;

    -- Referans kontrolu: Bu dile ait ceviri var mi?
    SELECT COUNT(*) INTO v_translation_count
    FROM catalog.localization_values lv
    WHERE lv.language_code = v_code;

    IF v_translation_count > 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.language.delete.has-translations';
    END IF;

    -- Soft delete (idempotent - zaten pasifse de hata vermez)
    UPDATE catalog.languages l
    SET is_active = FALSE
    WHERE l.language_code = v_code;
END;
$$;

COMMENT ON FUNCTION catalog.language_delete IS 'Soft deletes a language by setting is_active to false (checks for translations first)';
