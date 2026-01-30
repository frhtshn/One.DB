-- ================================================================
-- CURRENCY_UPDATE: Para birimi bilgilerini günceller
-- ================================================================

DROP FUNCTION IF EXISTS catalog.currency_update(CHAR(3), VARCHAR, VARCHAR, SMALLINT, BOOLEAN);

CREATE OR REPLACE FUNCTION catalog.currency_update(
    p_code CHAR(3),
    p_name VARCHAR(100),
    p_symbol VARCHAR(10),
    p_numeric_code SMALLINT,
    p_is_active BOOLEAN
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_code CHAR(3);
    v_name VARCHAR(100);
BEGIN
    v_code := UPPER(TRIM(p_code));
    v_name := TRIM(p_name);

    -- Mevcut mu kontrolu
    IF NOT EXISTS(SELECT 1 FROM catalog.currencies c WHERE c.currency_code = v_code) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.currency.not-found';
    END IF;

    -- Isim kontrolu
    IF p_name IS NULL OR LENGTH(v_name) < 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.currency.name-invalid';
    END IF;

    -- Guncelle
    UPDATE catalog.currencies c
    SET currency_name = v_name,
        symbol = p_symbol,
        numeric_code = p_numeric_code,
        is_active = p_is_active
    WHERE c.currency_code = v_code;
END;
$$;

COMMENT ON FUNCTION catalog.currency_update IS 'Updates currency details (name, symbol, numeric code, active status)';
