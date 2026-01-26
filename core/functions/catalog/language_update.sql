DROP FUNCTION IF EXISTS catalog.language_update(CHAR(2), VARCHAR, BOOLEAN);

-- Dil bilgilerini gunceller
CREATE OR REPLACE FUNCTION catalog.language_update(
    p_code CHAR(2),
    p_name VARCHAR(50),
    p_is_active BOOLEAN
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_code CHAR(2);
    v_name VARCHAR(50);
BEGIN
    v_code := LOWER(TRIM(p_code));
    v_name := TRIM(p_name);

    -- Mevcut mu kontrolu
    IF NOT EXISTS(SELECT 1 FROM catalog.languages l WHERE l.language_code = v_code) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.language.not-found';
    END IF;

    -- Isim kontrolu
    IF p_name IS NULL OR LENGTH(v_name) < 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.language.name-invalid';
    END IF;

    -- Guncelle
    UPDATE catalog.languages l
    SET language_name = v_name,
        is_active = p_is_active
    WHERE l.language_code = v_code;
END;
$$;

COMMENT ON FUNCTION catalog.language_update IS 'Updates language details (name, active status)';
