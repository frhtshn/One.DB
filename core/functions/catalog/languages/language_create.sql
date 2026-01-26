DROP FUNCTION IF EXISTS catalog.language_create(CHAR(2), VARCHAR);

-- Yeni dil olusturur
CREATE OR REPLACE FUNCTION catalog.language_create(
    p_code CHAR(2),
    p_name VARCHAR(50)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_code CHAR(2);
    v_name VARCHAR(50);
BEGIN
    -- Kod kontrolu (2 karakter)
    IF p_code IS NULL OR LENGTH(TRIM(p_code)) != 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.language.code-invalid';
    END IF;

    -- Isim kontrolu
    IF p_name IS NULL OR LENGTH(TRIM(p_name)) < 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.language.name-invalid';
    END IF;

    v_code := LOWER(TRIM(p_code));
    v_name := TRIM(p_name);

    -- Mevcut mu kontrolu
    IF EXISTS(SELECT 1 FROM catalog.languages l WHERE l.language_code = v_code) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.language.create.code-exists';
    END IF;

    -- Ekle
    INSERT INTO catalog.languages (language_code, language_name, is_active)
    VALUES (v_code, v_name, TRUE);
END;
$$;

COMMENT ON FUNCTION catalog.language_create IS 'Creates a new language';
