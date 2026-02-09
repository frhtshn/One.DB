-- ================================================================
-- LANGUAGE_GET: Tek dil detayı getirir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.language_get(CHAR(2));

CREATE OR REPLACE FUNCTION catalog.language_get(p_code CHAR(2))
RETURNS TABLE(language_code CHAR(2), language_name VARCHAR(50), is_active BOOLEAN)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM catalog.languages l WHERE l.language_code = LOWER(p_code)) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.language.not-found';
    END IF;

    RETURN QUERY
    SELECT l.language_code, l.language_name, l.is_active
    FROM catalog.languages l
    WHERE l.language_code = LOWER(p_code);
END;
$$;

COMMENT ON FUNCTION catalog.language_get IS 'Gets details of a specific language by code';
